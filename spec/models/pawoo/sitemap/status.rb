require 'rails_helper'

RSpec.describe Pawoo::Sitemap::Status do
  before do
    stub_const 'Pawoo::Sitemap::SITEMAPINDEX_SIZE', 1
  end

  let!(:status) { Fabricate(:status, reblogs_count: 5) }
  let(:page) { status.stream_entry.id }

  describe '.prepare' do
    subject do
      -> { Pawoo::Sitemap::Status.new(page).prepare }
    end

    it 'writes status id for sitemap' do
      subject.call
      expect(Rails.cache.read("pawoo:sitemap:status_indexes:#{page}").first).to eq status.id
    end
  end

  describe '.query' do
    subject do
      -> { Pawoo::Sitemap::Status.new(page).query }
    end

    before do
      Rails.cache.write("pawoo:sitemap:status_indexes:#{page}", [status.id])
    end

    it 'writes status id for sitemap' do
      expect(subject.call.first.id).to eq status.id
    end
  end
end
