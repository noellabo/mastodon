# frozen_string_literal: true
require 'sidekiq-scheduler'

class Pawoo::Scheduler::ReportTargetCleanupScheduler
  include Sidekiq::Worker

  def perform
    cleanup_ids = []
    Pawoo::ReportTarget.where(state: [:unresolved, :pending]).preload(:target).find_in_batches do |report_targets|
      cleanup_ids += report_targets.reject(&:target).map(&:id)
    end
    Pawoo::ReportTarget.where(id: cleanup_ids).update_all(state: :resolved) if cleanup_ids.present?
  end
end
