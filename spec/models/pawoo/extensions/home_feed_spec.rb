require 'rails_helper'

RSpec.describe HomeFeed, type: :model do
  let(:account) { Fabricate(:account) }

  subject { described_class.new(account) }

  describe '#get' do
    let!(:status_ids) do
      [
        Fabricate(:status, account: account, created_at: Time.current).id,
        Fabricate(:status, account: account, created_at: 1.day.ago).id,
        Fabricate(:status, account: account, created_at: (FeedManager::MAX_POPULATE_DURATION + 3.days).ago).id,
      ]
    end

    context 'when feed is being generated' do
      before do
        Redis.current.set("account:#{account.id}:regeneration", true)
      end

      it 'gets statuses with ids in the limited range from database' do
        results = subject.get(5)

        expect(results.map(&:id)).to eq status_ids.take(2)
        expect(results.first.attributes.keys).to include('id', 'updated_at')
      end
    end
  end
end
