# frozen_string_literal: true

class Pawoo::Sitemap::UserIndexesController < Pawoo::Sitemap::ApplicationController
  ALLOW_FOLLOWERS_COUNT = 10
  ALLOW_STATUS_COUNT    = 5

  def index
    @count = page_count(Account)
  end

  def show
    @accounts = page_details
  end

  private

  def page_details
    read_from_slave do
      Account.where('accounts.id > ? AND accounts.id <= ?', min_id, max_id)
             .where('accounts.followers_count >= ?', ALLOW_FOLLOWERS_COUNT)
             .where('accounts.statuses_count >= ?', ALLOW_STATUS_COUNT)
             .local.where(suspended: false)
             .load
    end
  end
end
