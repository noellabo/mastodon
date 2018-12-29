# frozen_string_literal: true

class ActivityPub::ProcessingWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(account_id, body)
    return if cancelled?

    ActivityPub::ProcessCollectionService.new.call(body, Account.find(account_id), override_timestamps: true)
  end

  def cancelled?
    Sidekiq.redis { |c| c.exists("cancelled-#{jid}") }
  end

  def self.cancel!(jid)
    Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 86400, 1) }
  end
end
