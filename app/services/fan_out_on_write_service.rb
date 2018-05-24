# frozen_string_literal: true

class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    raise Mastodon::RaceConditionError if status.visibility.nil?

    deliver_to_self(status) if status.account.local?

    render_anonymous_payload(status)

    if status.direct_visibility?
      deliver_to_mentioned_followers(status)
      deliver_to_direct_timelines(status)
    else
      deliver_to_followers(status)
      deliver_to_lists(status)
    end

    return if status.account.silenced? || !status.public_visibility? || status.reblog?

    deliver_to_hashtags(status)

    return if status.reply? && status.in_reply_to_account_id != status.account_id

    deliver_to_public(status)
    deliver_to_media(status) if status.media_attachments.any?
  end

  private

  def deliver_to_self(status)
    Rails.logger.debug "Delivering status #{status.id} to author"
    FeedManager.instance.push_to_home(status.account, status)
  end

  def deliver_to_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to followers"

    followers = status.account.followers.where(domain: nil).joins(:user).where('users.current_sign_in_at > ?', User::ACTIVE_DURATION.ago).select(:id).reorder(nil)

    batch_size = Rails.configuration.x.fan_out_job_batch_size
    if batch_size > 1
      followers.find_in_batches do |group|
        group.each_slice(batch_size) do |target_followers|
          FeedInsertWorker.perform_async(status.id, target_followers.map(&:id), :home)
        end
      end
    else
      followers.find_in_batches do |target_followers|
        FeedInsertWorker.push_bulk(target_followers) do |follower|
          [status.id, follower.id, :home]
        end
      end
    end
  end

  def deliver_to_lists(status)
    Rails.logger.debug "Delivering status #{status.id} to lists"

    lists = status.account.lists.joins(account: :user).where('users.current_sign_in_at > ?', User::ACTIVE_DURATION.days.ago).select(:id).reorder(nil)

    batch_size = Rails.configuration.x.fan_out_job_batch_size
    if batch_size > 1
      lists.find_in_batches do |group|
        group.each_slice(batch_size) do |target_lists|
          FeedInsertWorker.perform_async(status.id, target_lists.map(&:id), :list)
        end
      end
    else
      lists.find_in_batches do |target_lists|
        FeedInsertWorker.push_bulk(target_lists) do |list|
          [status.id, list.id, :list]
        end
      end
    end
  end

  def deliver_to_mentioned_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to mentioned followers"

    status.mentions.includes(:account).each do |mention|
      mentioned_account = mention.account
      next if !mentioned_account.local? || !mentioned_account.following?(status.account) || FeedManager.instance.filter?(:home, status, mention.account_id)
      FeedManager.instance.push_to_home(mentioned_account, status)
    end
  end

  def render_anonymous_payload(status)
    @payload = InlineRenderer.render(status, nil, :status)
    @payload = Oj.dump(event: :update, payload: @payload)
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtags"

    status.tags.pluck(:name).each do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag}:local", @payload) if status.local?
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering status #{status.id} to public timeline"

    Redis.current.publish('timeline:public', @payload)
    Redis.current.publish('timeline:public:local', @payload) if status.local?
  end

  def deliver_to_media(status)
    Rails.logger.debug "Delivering status #{status.id} to media timeline"

    Redis.current.publish('timeline:public:media', @payload)
    Redis.current.publish('timeline:public:local:media', @payload) if status.local?
  end

  def deliver_to_direct_timelines(status)
    Rails.logger.debug "Delivering status #{status.id} to direct timelines"

    status.mentions.includes(:account).each do |mention|
      Redis.current.publish("timeline:direct:#{mention.account.id}", @payload) if mention.account.local?
    end
    Redis.current.publish("timeline:direct:#{status.account.id}", @payload) if status.account.local?
  end
end
