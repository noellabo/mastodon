# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Sitemap::PrepareStatusesWorker do
  subject { described_class.new }

  before do
    stub_const 'Pawoo::Sitemap::SITEMAPINDEX_SIZE', 1
  end

  describe 'perform' do
    let(:status) { Fabricate(:status, reblogs_count: 5) }

    context 'when load_next_page is false' do
      let(:page) { status.stream_entry.id }

      it 'does not run worker' do
        allow(Pawoo::Sitemap::PrepareStatusesWorker).to receive(:perform_async)

        subject.perform(page)
        expect(Pawoo::Sitemap::PrepareStatusesWorker).not_to have_received(:perform_async)
      end
    end

    xcontext 'when load_next_page is true' do
      context 'when page is not the last' do
        let(:page) { status.stream_entry.id }

        it 'runs worker with next page' do
          allow(Pawoo::Sitemap::PrepareStatusesWorker).to receive(:perform_async)

          subject.perform(page, true)
          expect(Pawoo::Sitemap::PrepareStatusesWorker).to have_received(:perform_async).with(page + 1, true)
        end
      end

      context 'when page is the last' do
        let(:page) { status.stream_entry.id + 1 }

        it 'does not run worker' do
          allow(Pawoo::Sitemap::PrepareStatusesWorker).to receive(:perform_async)

          subject.perform(page, true)
          expect(Pawoo::Sitemap::PrepareStatusesWorker).not_to have_received(:perform_async)
        end
      end
    end
  end
end
