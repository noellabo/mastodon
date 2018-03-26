# frozen_string_literal: true

class Pawoo::Sitemap
  attr_reader :page

  SITEMAPINDEX_SIZE = 10_000

  def self.page_count
    (paging_class.maximum(:id) / SITEMAPINDEX_SIZE) + 1
  end

  def initialize(page)
    @page = page
  end

  private

  def min_id
    (page.to_i - 1) * SITEMAPINDEX_SIZE
  end

  def max_id
    min_id + SITEMAPINDEX_SIZE
  end

  def redis_key
    "pawoo:sitemap:#{self.class::REDIS_KEY}:#{page}"
  end

  def read_from_cache
    Rails.cache.read(redis_key)
  end

  def store_to_cache(ids)
    Rails.cache.write(redis_key, ids, expired_in: 2.days)
  end

end
