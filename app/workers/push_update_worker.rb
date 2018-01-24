# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(ids, status_id, timeline_type = :home)
    status = Status.find(status_id)

    case timeline_type.to_sym
    when :home
      Account.where(id: ids).each do |account|
        publish(status, account, "timeline:#{account.id}")
      end
    when :list
      List.where(id: ids).preload(:account).each do |list|
        publish(status, list.account, "timeline:list:#{list.id}")
      end
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def publish(status, account, timeline_id)
    message = InlineRenderer.render(status, account, :status)
    Redis.current.publish(timeline_id, Oj.dump(event: :update, payload: message, queued_at: (Time.now.to_f * 1000.0).to_i))
  end
end
