# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Sitemap::PrepareUsersWorker do
  subject { described_class.new }

  before do
    stub_const 'Pawoo::Sitemap::SITEMAPINDEX_SIZE', 1
  end

  describe 'perform' do
    let!(:account) { Fabricate(:account, user: Fabricate(:user),followers_count: 10, statuses_count: 5) }

    context 'page is not the last' do
      let(:page) { account.user.id }

      it 'runs worker with next page' do
        allow(Pawoo::Sitemap::PrepareUsersWorker).to receive(:perform_async)

        subject.perform(page)
        expect(Pawoo::Sitemap::PrepareUsersWorker).to have_received(:perform_async).with(page + 1)
      end
    end

    context 'page is the last' do
      let(:page) { account.user.id + 1 }

      it 'does not run worker' do
        allow(Pawoo::Sitemap::PrepareUsersWorker).to receive(:perform_async)

        subject.perform(page)
        expect(Pawoo::Sitemap::PrepareUsersWorker).not_to have_received(:perform_async)
      end
    end
  end
end
