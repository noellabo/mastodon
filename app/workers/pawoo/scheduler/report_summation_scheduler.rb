# frozen_string_literal: true
require 'sidekiq-scheduler'

class Pawoo::Scheduler::ReportSummationScheduler
  include Sidekiq::Worker

  def perform
    report_summation = Pawoo::ReportSummation.build_summation(1.day.ago)
    report_summation.save!
  end
end
