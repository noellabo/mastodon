# frozen_string_literal: true

class Pawoo::Sitemap::UserIndexesController < ApplicationController
  SITEMAPINDEX_SIZE     = 50_000
  ALLOW_FOLLOWERS_COUNT = 1000

  def index
    read_from_slave do
      @count = (User.maximum(:id) / SITEMAPINDEX_SIZE) + 1
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
    User.select('MAX(statuses.id)')
        .select('MAX(statuses.updated_at) as updated_at')
        .select('accounts.username as username')
        .select('followers_count')
        .where('users.id > ? AND users.id <= ?', min_id, max_id)
        .where('accounts.followers_count >= ?', ALLOW_FOLLOWERS_COUNT)
        .group('accounts.id').joins(:account).joins(account: :statuses)
  end

  def read_from_slave
    SwitchPoint.with_readonly(:pawoo_slave) { yield }
  end
end
