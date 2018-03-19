# frozen_string_literal: true

class Pawoo::Sitemap::ApplicationController < ApplicationController
  SITEMAPINDEX_SIZE = 50_000

  private

  def page_count(klass)
    read_from_slave do
      (klass.maximum(:id) / SITEMAPINDEX_SIZE) + 1
    end
  end

  def min_id
    (params[:page].to_i - 1) * SITEMAPINDEX_SIZE
  end

  def max_id
    min_id + SITEMAPINDEX_SIZE
  end

  def read_from_slave
    SwitchPoint.with_readonly(:pawoo_slave) do
      return yield
    end
  end
end
