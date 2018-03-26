# frozen_string_literal: true

class Pawoo::Sitemap::StatusIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = page_count(StreamEntry)
    end
  end

  def show
    @status_pages = page_details
  end

  private

  def page_details
    status_ids = Rails.cache.read("pawoo:sitemap:statuses_indexes:#{@page}")
    return [] if status_ids.blank?

    read_from_slave do
      Status.joins(:account)
            .select('statuses.id')
            .select('statuses.updated_at')
            .select('accounts.username')
            .select('statuses.reblogs_count')
            .where(id: status_ids)
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
