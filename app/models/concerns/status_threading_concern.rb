# frozen_string_literal: true

module StatusThreadingConcern
  extend ActiveSupport::Concern

  def ancestors(account = nil)
    find_statuses_from_tree_path(ancestor_ids, account)
  end

  def descendants(account = nil)
    find_statuses_from_tree_path(descendant_ids, account)
  end

  private

  def ancestor_ids
    Rails.cache.fetch("ancestors:#{id}") do
      ancestors_without_self.pluck(:id)
    end
  end

  def ancestors_without_self
    ancestor_statuses - [self]
  end

  def ancestor_statuses
    Status.find_by_sql([<<-SQL.squish, id: id])
      WITH RECURSIVE search_tree(id, in_reply_to_id, path)
      AS (
        SELECT id, in_reply_to_id, ARRAY[id]
        FROM statuses
        WHERE id = :id
        UNION ALL
        SELECT statuses.id, statuses.in_reply_to_id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.id = search_tree.in_reply_to_id
        WHERE NOT statuses.id = ANY(path)
      )
      SELECT id
      FROM search_tree
      ORDER BY path DESC
    SQL
  end

  def descendant_ids
    descendants_without_self.pluck(:id)
  end

  def descendants_without_self
    descendant_statuses - [self]
  end

  def descendant_statuses
    Status.find_by_sql([<<-SQL.squish, id: id])
      WITH RECURSIVE search_tree(id, path)
      AS (
        SELECT id, ARRAY[id]
        FROM statuses
        WHERE id = :id
        UNION ALL
        SELECT statuses.id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.in_reply_to_id = search_tree.id
        WHERE NOT statuses.id = ANY(path)
      )
      SELECT id
      FROM search_tree
      ORDER BY path
    SQL
  end

  def find_statuses_from_tree_path(ids, account)
    statuses    = statuses_with_accounts(ids).to_a
    account_ids = statuses.map(&:account_id).uniq
    domains     = statuses.map(&:account_domain).compact.uniq
    relations   = relations_map_for_account(account, account_ids, domains)

    statuses.reject! { |status| filter_from_context?(status, account, relations) }

    # Order ancestors/descendants by tree path
    statuses.sort_by! { |status| ids.index(status.id) }
  end

  def relations_map_for_account(account, account_ids, domains)
    return {} if account.nil?

    {
      blocking: Account.blocking_map(account_ids, account.id),
      blocked_by: Account.blocked_by_map(account_ids, account.id),
      muting: Account.muting_map(account_ids, account.id),
      following: Account.following_map(account_ids, account.id),
      domain_blocking_by_domain: Account.domain_blocking_map_by_domain(domains, account.id),
    }
  end

  def statuses_with_accounts(ids)
    Status.where(id: ids).includes(:account)
  end

  def filter_from_context?(status, account, relations)
    StatusFilter.new(status, account, relations).filtered?
  end
end
