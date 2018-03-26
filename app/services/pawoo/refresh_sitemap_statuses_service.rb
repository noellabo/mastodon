# frozen_string_literal: true

class Pawoo::RefreshSitemapStatusesService
  include Pawoo::Sitemap
  include Pawoo::SlaveReader

  ALLOW_REBLOGS_COUNT = 5

  def call(page)
    read_from_slave do
      @page = page

      status_ids = StreamEntry.joins(:status).joins(status: :account)
                     .where('stream_entries.id > ?', min_id)
                     .where('stream_entries.id <= ?', max_id)
                     .where('statuses.reblogs_count >= ?', ALLOW_REBLOGS_COUNT)
                     .where(hidden: false)
                     .merge(status_scope).merge(account_scope)
                     .pluck(:activity_id)

      puts status_ids

      Rails.cache.write("pawoo:sitemap:statuses_indexes:#{@page}", status_ids, expired_in: 2.days)
    end

    next_page = page + 1
    Pawoo::RefreshSitemapStatusesWorker.perform_async(next_page) if next_page <= page_count(StreamEntry)
  end

  private

  def status_scope
    Status.local.where(visibility: [:public, :unlisted]).without_reblogs.published.reorder(nil)
  end

  def account_scope
    Account.local.where(suspended: false)
  end
end
