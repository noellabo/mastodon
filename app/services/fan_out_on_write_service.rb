# frozen_string_literal: true

class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    raise Mastodon::RaceConditionError if status.visibility.nil?

    render_anonymous_payload(status)

    if status.direct_visibility?
      deliver_to_own_conversation(status)
    elsif status.limited_visibility?
      deliver_to_mentioned_followers(status)
    else
      deliver_to_self(status) if status.account.local?
      deliver_to_followers(status)
      deliver_to_lists(status)
      deliver_to_self_lists(status)
    end

    return if status.account.silenced? || !status.public_visibility? || status.reblog?

    deliver_to_hashtags(status)
    deliver_to_hashtag_followers(status)
    deliver_to_subscribers(status)
    deliver_to_keyword_subscribers(status)

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

    status.account.followers_for_local_distribution.select(:id).reorder(nil).find_in_batches do |followers|
      FeedInsertWorker.push_bulk(followers) do |follower|
        [status.id, follower.id, :home]
      end
    end
  end

  def deliver_to_subscribers(status)
    Rails.logger.debug "Delivering status #{status.id} to subscribers"

    status.account.subscribers_for_local_distribution.select(:id).reorder(nil).find_in_batches do |subscribings|
      FeedInsertWorker.push_bulk(subscribings) do |subscribing|
        [status.id, subscribing.id, :home]
      end
    end
  end

  def deliver_to_keyword_subscribers(status)
    Rails.logger.debug "Delivering status #{status.id} to keyword subscribers"

    text = [status.spoiler_text, Formatter.instance.plaintext(status)].concat(status.media_attachments.map(&:description)).concat(status.preloadable_poll ? status.preloadable_poll.options : []).join("\n\n")
    match_accounts = []

    local_followers   = status.account.followers.local.select(:id)
    local_subscribers = status.account.subscribers.local.select(:id)

    KeywordSubscribe.where.not(account_id: local_followers).where.not(account_id: local_subscribers).order(:account_id).each do |keyword_subscribe|
      next if match_accounts[-1] == keyword_subscribe.account_id
      if Regexp.new(keyword_subscribe.regexp ? keyword_subscribe.keyword : keyword_subscribe.keyword.gsub(/,/, "|"), keyword_subscribe.ignorecase).match?(text)
        match_accounts << keyword_subscribe.account_id
      end
    end
    FeedInsertWorker.push_bulk(match_accounts) do |match_account|
      [status.id, match_account, :home]
    end
  end

  def deliver_to_lists(status)
    Rails.logger.debug "Delivering status #{status.id} to lists"

    status.account.lists_for_local_distribution.select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [status.id, list.id, :list]
      end
    end
  end

  def deliver_to_self_lists(status)
    Rails.logger.debug "Delivering status #{status.id} to own lists"

    List.where("account_id = ? AND title LIKE ?", status.account.id, "%+").select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [status.id, list.id, :list]
      end
    end
  end

  def deliver_to_mentioned_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to limited followers"

    FeedInsertWorker.push_bulk(status.mentions.includes(:account).map(&:account).select { |mentioned_account| mentioned_account.local? && mentioned_account.following?(status.account) }) do |follower|
      [status.id, follower.id, :home]
    end
  end

  def render_anonymous_payload(status)
    @payload = InlineRenderer.render(status, nil, :status)
    @payload = Oj.dump(event: :update, payload: @payload)
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtags"

    status.tags.pluck(:name).each do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", @payload) if status.local?
      List.where('title ILIKE ?', "%##{hashtag}%").select(:id).reorder(nil).find_in_batches do |lists|
        FeedInsertWorker.push_bulk(lists) do |list|
          [status.id, list.id, :list]
        end
      end
    end
  end

  def deliver_to_hashtag_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtag followers"

    FeedInsertWorker.push_bulk(FollowTag.where(tag: status.tags).pluck(:account_id).uniq) do |follower|
      [status.id, follower, :home]
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering status #{status.id} to public timeline"

    Redis.current.publish('timeline:public', @payload)
  end

  def deliver_to_media(status)
    Rails.logger.debug "Delivering status #{status.id} to media timeline"

    Redis.current.publish('timeline:public:media', @payload)
  end

  def deliver_to_own_conversation(status)
    AccountConversation.add_status(status.account, status)
  end
end
