# frozen_string_literal: true

class Pawoo::Sitemap::UserIndexesController < ApplicationController
  SITEMAPINDEX_SIZE     = 50_000
  ALLOW_FOLLOWERS_COUNT = 1_000
  ALLOW_STATUS_COUNT    = 5

  def index
    read_from_slave do
      @count = (Account.maximum(:id) / SITEMAPINDEX_SIZE) + 1
    end
  end

  def show
    min_id = (params[:page].to_i - 1) * SITEMAPINDEX_SIZE
    max_id = min_id + SITEMAPINDEX_SIZE
    read_from_slave do
      @statuses = user_page_statuses(min_id, max_id)
    end
  end

  private

  def user_page_statuses(min_id, max_id)
    Account.where('accounts.id > ? AND accounts.id <= ?', min_id, max_id)
           .where('accounts.followers_count >= ?', ALLOW_FOLLOWERS_COUNT)
           .where('accounts.statuses_count >= ?', ALLOW_STATUS_COUNT)
           .where(domain: nil)
  end

  def read_from_slave
    SwitchPoint.with_readonly(:pawoo_slave) { yield }
  end
end
