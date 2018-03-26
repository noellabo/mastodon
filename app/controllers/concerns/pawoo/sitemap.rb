# frozen_string_literal: true

module Pawoo::Sitemap
  SITEMAPINDEX_SIZE = 50_000

  private

  def page_count(klass)
    (klass.maximum(:id) / SITEMAPINDEX_SIZE) + 1
  end

  def min_id
    (@page.to_i - 1) * SITEMAPINDEX_SIZE
  end

  def max_id
    min_id + SITEMAPINDEX_SIZE
  end
end
