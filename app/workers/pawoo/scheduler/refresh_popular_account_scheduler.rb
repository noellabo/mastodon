# frozen_string_literal: true
require 'sidekiq-scheduler'

class Pawoo::Scheduler::RefreshPopularAccountScheduler
  include Sidekiq::Worker

  def perform
    Pawoo::RefreshPopularAccountService.new.call
  end
end
