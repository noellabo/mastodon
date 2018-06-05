require 'rails_helper'

RSpec.describe StatusPagination do
  let(:instance) { described_class.new(status, account) }
  let!(:previous_status) { Fabricate(:status, id: 1, account: status.account) }
  let!(:next_status) { Fabricate(:status, id: 3, account: status.account) }
  let!(:account) { Fabricate(:account) }

  describe '#next' do
    subject { instance.next }

    context 'account has authority' do
      let!(:status) { Fabricate(:status, id: 2, account: account) }
      it { is_expected.to eq(next_status) }
    end
  end

  describe '#previous' do
    subject { instance.previous }

    context 'account has authority' do
      let!(:status) { Fabricate(:status, id: 2, account: account) }
      it { is_expected.to eq(previous_status) }
    end
  end
end
