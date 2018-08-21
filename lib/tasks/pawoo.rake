# frozen_string_literal: true

namespace :pawoo do
  namespace :maintenance do
    desc 'Update counter caches'
    task migrate_from_pinned_status_to_status_pin: :environment do
      Rails.logger.debug 'Migrating from PinnedStatus to StatusPin...'

      PinnedStatus.order(:id).find_each do |pinned_status|
        StatusPin.create(
          account_id: pinned_status.account_id,
          status_id: pinned_status.status_id,
          created_at: pinned_status.created_at,
          updated_at: pinned_status.updated_at
        )
      end

      Rails.logger.debug 'Done!'
    end

    desc 'Calculate Redis prefix frequencies'
    task redis_frequencies: :environment do
      hash = {}
      cursor = 0
      while cursor != '0'
        cursor, keys = Redis.current.scan(cursor)
        keys.each do |key|
          scrubbed = key.scrub('?')
          colon = scrubbed.rindex(':')
          prefix = colon.nil? ? scrubbed : scrubbed[0..colon]
          old = hash[prefix]
          hash[prefix] = old.nil? ? 1 : old + 1
        end
      end

      pp hash
    end
  end

  namespace :dev do
    desc 'Set popular accounts'
    task set_popular_accounts: :environment do
      accounts = Account.limit(100)
      Redis.current.zadd(Pawoo::RefreshPopularAccountService::REDIS_KEY, accounts.map { |account| [account.id, account.id] })
    end
  end
end
