# frozen_string_literal: true

class Pawoo::Form::OauthRegistration
  include ActiveModel::Model
  include TypeAttributes

  PRIVATE_USER_NAME = /\Auser_/

  attr_accessor :user, :oauth_authentication, :avatar, :email_confirmed, :locale
  attr_accessor :provider, :uid
  type_attribute :email, :string
  type_attribute :username, :string

  validate :validate_user

  class << self
    def from_omniauth_auth(omniauth_auth)
      case omniauth_auth['provider']
      when 'pixiv'
        new(
          provider: 'pixiv',
          uid: omniauth_auth['uid'],
          email_confirmed: omniauth_auth['extra']['raw_info']['is_mail_authorized'],
          email: omniauth_auth['info']['email'],
          username: normalize_username(omniauth_auth['info']['account']),
          avatar: fetch_pixiv_avatar(omniauth_auth['info']['avatar'])
        )
      else
        new
      end
    end

    private

    # Normalize username for format validator of Account#username
    def normalize_username(string)
      username = string.to_s.tr('-', '_').remove(/[^a-z0-9_]/i, '')
      username unless username.match?(PRIVATE_USER_NAME)
    end

    def fetch_pixiv_avatar(url)
      image = OpenURI.open_uri(url, 'Referer' => "https://#{Rails.configuration.x.local_domain}")
      account = Account.new(avatar: image)
      account.valid?
      account.avatar unless account.errors.key?(:avatar)
    rescue
      nil
    end
  end

  def email_confirmed?
    email.present? && email_confirmed
  end

  def email=(value)
    @email = value unless email_confirmed?
  end

  def save
    return false if invalid?

    ApplicationRecord.transaction do
      self.user = User.new(user_attributes)
      user.skip_confirmation_notification! if email_confirmed?
      self.oauth_authentication = user.oauth_authentications.build(provider: provider, uid: uid)
      user.save! && user.create_initial_password_usage! && oauth_authentication.save!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def validate_user
    user = User.new(user_attributes)
    user.valid?

    [user, user.account].each do |record|
      record.errors.each do |key, value|
        errors.add(key, value) if respond_to?(key)
      end
    end
  end

  def user_attributes
    password = SecureRandom.base64
    confirmed_at = Time.current if email_confirmed?

    {
      email: email,
      locale: locale,
      password: password,
      password_confirmation: password,
      confirmed_at: confirmed_at,
      account_attributes: {
        username: username,
        avatar: avatar
      }
    }
  end
end
