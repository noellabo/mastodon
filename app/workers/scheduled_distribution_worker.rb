# frozen_string_literal: true

class ScheduledDistributionWorker
  include Sidekiq::Worker

  def perform(status_id)
    old_status = Status.find(status_id)
    new_status = old_status.dup
    new_status.uri = nil

    ApplicationRecord.transaction do
      new_status.save!
      old_status.media_attachments.update_all status_id: new_status.id
      new_status.update_attribute(:preview_cards, old_status.preview_cards)
      old_status.pixiv_cards.update_all status_id: new_status.id
      new_status.update_attribute(:tags, old_status.tags)
      old_status.reload

      old_status.stream_entry&.destroy!
      old_status.destroy!
    end

    DistributionService.new.call(new_status)
  rescue ActiveRecord::RecordNotFound # rescue in case of race removal of statuses
    nil
  end
end
