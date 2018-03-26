# frozen_string_literal: true
require 'sidekiq-scheduler'

class Pawoo::Scheduler::RefreshSitemapStatusesScheduler
  include Sidekiq::Worker

  def perform
    Pawoo::RefreshSitemapStatusesWorker.perform_async(1)
  end
end
