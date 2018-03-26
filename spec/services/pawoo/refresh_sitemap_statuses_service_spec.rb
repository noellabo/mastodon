require 'rails_helper'

describe Pawoo::RefreshSitemapStatusesService do
  describe '.call' do
    subject do
      -> { Pawoo::RefreshSitemapStatusesService.new.call(page) }
    end

    let!(:status) { Fabricate(:status, reblogs_count: 5) }

    before do
      Pawoo::Sitemap
      stub_const 'Pawoo::Sitemap::SITEMAPINDEX_SIZE', 1
    end

    context 'when page is not the last' do
      let(:page) { status.stream_entry.id }

      it 'writes status id for sitemap' do
        subject.call
        expect(Rails.cache.read("pawoo:sitemap:statuses_indexes:#{page}").first).to eq status.id
      end

      it 'runs worker with next page' do
        allow(Pawoo::RefreshSitemapStatusesWorker).to receive(:perform_async)

        subject.call
        expect(Pawoo::RefreshSitemapStatusesWorker).to have_received(:perform_async).with(page + 1)
      end
    end

    context 'page is the last' do
      let(:page) { status.stream_entry.id + 1 }

      it 'does not run worker' do
        allow(Pawoo::RefreshSitemapStatusesWorker).to receive(:perform_async)

        subject.call
        expect(Pawoo::RefreshSitemapStatusesWorker).not_to have_received(:perform_async)
      end
    end
  end
end
