# frozen_string_literal: true

class Pawoo::Sitemap::StatusIndexesController < Pawoo::Sitemap::ApplicationController
  ALLOW_REBLOGS_COUNT = 5

  def index
    @count = page_count(StreamEntry)
  end

  def show
    @status_pages = page_details
  end

  private

  def page_details
    read_from_slave do
      StreamEntry.joins(:status).joins(status: :account)
                 .select('statuses.id')
                 .select('statuses.updated_at')
                 .select('accounts.username')
                 .select('statuses.reblogs_count')
                 .where('stream_entries.id > ?', min_id)
                 .where('stream_entries.id <= ?', max_id)
                 .where('statuses.reblogs_count >= ?', ALLOW_REBLOGS_COUNT)
                 .where(hidden: false)
                 .merge(status_scope).merge(account_scope)
                 .load
    end
  end

  def status_scope
    Status.local.where(visibility: [:public, :unlisted]).without_reblogs.published.reorder(nil)
  end

  def account_scope
    Account.local.where(suspended: false)
  end
end
