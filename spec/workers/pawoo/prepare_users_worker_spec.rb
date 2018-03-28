# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Sitemap::PrepareUsersWorker do
  subject { described_class.new }

  before do
    stub_const 'Pawoo::Sitemap::SITEMAPINDEX_SIZE', 1
  end

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  describe 'perform' do
    let!(:account) { Fabricate(:account, user: Fabricate(:user),followers_count: 10, statuses_count: 5) }
    let(:sitemap) { double }
    let(:continuously_key) { nil }

    shared_examples 'prepares sitemap' do
      it 'prepares sitemap' do
        allow(Pawoo::Sitemap::User).to receive(:new).and_return(sitemap)
        allow(sitemap).to receive(:prepare)

        subject.perform(page, continuously_key)

        expect(Pawoo::Sitemap::User).to have_received(:new).with(page)
        expect(sitemap).to have_received(:prepare)
      end
    end

    shared_examples 'does nothing' do
      it 'does nothing' do
        allow(Pawoo::Sitemap::User).to receive(:new).and_return(sitemap)
        allow(sitemap).to receive(:prepare)

        subject.perform(page, continuously_key)

        expect(Pawoo::Sitemap::User).not_to have_received(:new).with(page)
        expect(sitemap).not_to have_received(:prepare)
      end
    end

    context 'when load_next_page is not set' do
      let(:page) { account.user.id }

      include_examples 'prepares sitemap'

      it 'does not run worker' do
        allow(Pawoo::Sitemap::PrepareUsersWorker).to receive(:perform_async)

        subject.perform(page)
        expect(Pawoo::Sitemap::PrepareUsersWorker).not_to have_received(:perform_async)
      end
    end

    context 'when load_next_page is set' do
      let(:continuously_key) { 'continuously_key' }

      context 'when page is the first' do
        let(:page) { 1 }

        context 'when there is no lock key' do
          include_examples 'prepares sitemap'

          it 'set lock key' do
            subject.perform(page, continuously_key)
            expect(Redis.current.get("pawoo:sitemap:prepare_users")).to eq continuously_key
          end
        end

        context 'when there is a lock key' do
          before do
            Redis.current.set("pawoo:sitemap:prepare_users", 'continuously_key')
          end

          include_examples 'does nothing'
        end
      end

      context 'when page is not the last' do
        let(:page) { account.user.id }

        context 'when the lock keys match' do
          before do
            Redis.current.set("pawoo:sitemap:prepare_users", continuously_key)
          end

          include_examples 'prepares sitemap'

          it 'runs worker with next page' do
            allow(Pawoo::Sitemap::PrepareUsersWorker).to receive(:perform_async)

            subject.perform(page, continuously_key)
            expect(Pawoo::Sitemap::PrepareUsersWorker).to have_received(:perform_async).with(page + 1, continuously_key)
          end
        end

        context 'when the lock keys do not match' do
          before do
            Redis.current.set("pawoo:sitemap:prepare_users", 'another_continuously_key')
          end

          include_examples 'does nothing'
        end
      end

      context 'when page is the last' do
        let(:page) { account.user.id + 1 }

        it 'does not run worker' do
          allow(Pawoo::Sitemap::PrepareUsersWorker).to receive(:perform_async)

          subject.perform(page, continuously_key)
          expect(Pawoo::Sitemap::PrepareUsersWorker).not_to have_received(:perform_async)
        end

        it 'deletes lock key' do
          subject.perform(page, continuously_key)

          expect(Redis.current.exists("pawoo:sitemap:prepare_users")).to be false
        end
      end
    end
  end
end
