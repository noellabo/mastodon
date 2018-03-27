# frozen_string_literal: true

class Pawoo::Sitemap::PrepareUsersWorker
  include Sidekiq::Worker
  include Pawoo::SlaveReader

  sidekiq_options queue: 'pull'

  def perform(page)
    return
    read_from_slave do
      Pawoo::Sitemap::User.new(page).prepare

      next_page = page + 1
      Pawoo::Sitemap::PrepareUsersWorker.perform_async(next_page) if next_page <= Pawoo::Sitemap::User.page_count
    end
  end
end
