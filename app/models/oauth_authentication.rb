# == Schema Information
#
# Table name: oauth_authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OauthAuthentication < ApplicationRecord
  belongs_to :user, required: true
  has_many :pixiv_follows, dependent: :delete_all

  validates :provider, :uid, presence: true
  validates :user_id, uniqueness: { scope: :provider }
  validates :provider, inclusion: Devise.omniauth_configs.keys.map(&:to_s)
  validates :uid, uniqueness: { scope: :provider }

  before_destroy :prevent_destory_if_initial_password_usage_is_exists

  def force_destroy
    transaction do
      user.initial_password_usage&.destroy!
      destroy!
    end

    true
  rescue ActiveRecord::RecordNotDestroyed
    false
  end

  private

  def prevent_destory_if_initial_password_usage_is_exists
    throw(:abort) if user.initial_password_usage && !user.initial_password_usage.destroyed?
  end
end
