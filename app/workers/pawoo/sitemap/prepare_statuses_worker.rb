# frozen_string_literal: true

class Pawoo::Sitemap::PrepareStatusesWorker
  include Sidekiq::Worker
  include Pawoo::SlaveReader

  sidekiq_options queue: 'pull'

  def perform(page)
    return
    read_from_slave do
      Pawoo::Sitemap::Status.new(page).prepare

      next_page = page + 1
      Pawoo::Sitemap::PrepareStatusesWorker.perform_async(next_page) if next_page <= Pawoo::Sitemap::Status.page_count
    end
  end
end
