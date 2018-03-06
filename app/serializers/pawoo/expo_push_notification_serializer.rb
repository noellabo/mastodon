# frozen_string_literal: true

class Pawoo::ExpoPushNotificationSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at

  belongs_to :account
  belongs_to :from_account
  belongs_to :target_status, key: :status, if: :status_type?

  def id
    object.id.to_s
  end

  def status_type?
    [:favourite, :reblog, :mention].include?(object.type)
  end

  class AccountSerializer < ActiveModel::Serializer
    include RoutingHelper

    attributes :id, :username, :acct, :display_name, :locked, :created_at, :avatar, :avatar_static

    def id
      object.id.to_s
    end

    def avatar
      full_asset_url(object.avatar_original_url)
    end

    def avatar_static
      full_asset_url(object.avatar_static_url)
    end
  end

  class StatusSerializer < ActiveModel::Serializer
    attributes :id, :created_at, :in_reply_to_id, :in_reply_to_account_id, :sensitive, :spoiler_text, :visibility, :content

    def id
      object.id.to_s
    end

    def in_reply_to_id
      object.in_reply_to_id&.to_s
    end

    def in_reply_to_account_id
      object.in_reply_to_account_id&.to_s
    end

    def content
      Formatter.instance.plaintext(object)
    end
  end
end
