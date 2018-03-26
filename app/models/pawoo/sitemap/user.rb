# frozen_string_literal: true

class Pawoo::Sitemap::User < Pawoo::Sitemap
  REDIS_KEY = 'user_indexes'
  ALLOW_FOLLOWERS_COUNT = 10
  ALLOW_STATUS_COUNT    = 5

  def self.paging_class
    ::User
  end

  def query
    account_ids = read_from_cache

    Account.where(id: account_ids).merge(account_scope)
  end

  def prepare
    account_ids = ::User.joins(:account)
                        .where('users.id > ?', min_id)
                        .where('users.id <= ?', max_id)
                        .merge(account_scope)
                        .pluck(:account_id)

    store_to_cache(account_ids)
  end

  private

  def account_scope
    Account.local.where(suspended: false)
      .where('accounts.followers_count >= ?', ALLOW_FOLLOWERS_COUNT)
      .where('accounts.statuses_count >= ?', ALLOW_STATUS_COUNT)

  end
end
