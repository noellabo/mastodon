# frozen_string_literal: true

class Pawoo::Sitemap::Status < Pawoo::Sitemap
  REDIS_KEY = 'status_indexes'
  ALLOW_REBLOGS_COUNT = 5

  def self.paging_class
    StreamEntry
  end

  def query
    status_ids = read_from_cache

    ::Status.joins(:account)
            .select('statuses.id')
            .select('statuses.updated_at')
            .select('accounts.username')
            .select('statuses.reblogs_count')
            .where(id: status_ids)
            .merge(status_scope).merge(account_scope)
  end

  def prepare
    status_ids = StreamEntry.joins(:status).joins(status: :account)
                            .where('stream_entries.id > ?', min_id)
                            .where('stream_entries.id <= ?', max_id)
                            .where(hidden: false)
                            .merge(status_scope).merge(account_scope)
                            .pluck(:activity_id)

    store_to_cache(status_ids)
  end

  private

  def status_scope
    ::Status.local.without_reblogs.published
            .where(visibility: [:public, :unlisted])
            .where('statuses.reblogs_count >= ?', ALLOW_REBLOGS_COUNT)
            .reorder(nil)
  end

  def account_scope
    Account.local.where(suspended: false)
  end
end
