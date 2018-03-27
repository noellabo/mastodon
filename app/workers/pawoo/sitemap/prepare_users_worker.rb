# frozen_string_literal: true

class Pawoo::Sitemap::PrepareUsersWorker
  include Sidekiq::Worker
  include Pawoo::SlaveReader

  sidekiq_options queue: 'pull', unique: :until_executed

  def perform(page, load_next_page = false)
    read_from_slave do
      Pawoo::Sitemap::User.new(page).prepare

      if load_next_page
        next_page = page + 1
        Pawoo::Sitemap::PrepareUsersWorker.perform_async(next_page, true) if next_page <= Pawoo::Sitemap::User.page_count
      end
    end
  end
end
