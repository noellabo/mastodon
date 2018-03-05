# frozen_string_literal: true

class Pawoo::ExpoPushWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(notification_id, recipient_id)
    @notification = Notification.find(notification_id)
    @recipient = Account.find(recipient_id)

    I18n.with_locale(@recipient.user.locale || I18n.default_locale) do
      send_push_notifications
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def send_push_notifications
    message = build_message
    messages = @recipient.user.expo_push_tokens.map { |expo_push_token| message.merge(to: expo_push_token.token) }

    ::Exponent::Push::Client.new.publish messages
  end

  def build_message
    data = InlineRenderer.render(@notification, @recipient, :pawoo_expo_push_notification)
    from_account_name = @notification.from_account.display_name.presence || @notification.from_account.username
    title = I18n.t("pawoo.expo_push_notifications.#{@notification.type}", name: from_account_name)
    body = @notification.target_status.present? ? Formatter.instance.plaintext(@notification.target_status) : nil

    message = {
      data: data,
      priority: 'high',
    }

    if body.nil?
      message[:body] = title
    else
      message[:title] = title
      message[:body] = body
    end

    message
  end
end
