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
      StreamEntry.select('statuses.id')
                 .select('statuses.updated_at')
                 .select('accounts.username')
                 .select('statuses.reblogs_count')
                 .where('stream_entries.activity_type = \'Status\'')
                 .where('stream_entries.id > ?', min_id)
                 .where('stream_entries.id <= ?', max_id)
                 .where('statuses.reblogs_count >= ?', ALLOW_REBLOGS_COUNT)
                 .where('statuses.local = TRUE')
                 .joins(:status).joins(status: :account)
    end
  end
end
