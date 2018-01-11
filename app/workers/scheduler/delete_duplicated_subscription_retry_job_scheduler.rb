# frozen_string_literal: true

require 'sidekiq-scheduler'

class Scheduler::DeleteDuplicatedSubscriptionRetryJobScheduler
  include Sidekiq::Worker

  def perform
    retries = Sidekiq::RetrySet.new
    subscribe_worker_retries = retries.select { |entry| entry.item['class'] == 'Pubsubhubbub::SubscribeWorker' }
    subscribe_worker_retries.group_by { |entry| entry.item['args'][0] }.each_value do |entries|
      # 一番昔に作られたジョブ以外を消す
      (entries.sort_by { |entry| entry.item['created_at'] })[1..-1]&.each(&:delete)
    end
  end
end
