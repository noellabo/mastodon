# frozen_string_literal: true
require 'sidekiq-scheduler'

class Pawoo::Scheduler::PrepareSitemapScheduler
  include Sidekiq::Worker

  def perform
    Pawoo::Sitemap::PrepareStatusesWorker.perform_async(1)
    Pawoo::Sitemap::PrepareUsersWorker.perform_async(1)
  end
end
