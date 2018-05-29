# frozen_string_literal: true
# == Schema Information
#
# Table name: firebase_cloud_messaging_tokens
#
#  id       :integer          not null, primary key
#  user_id  :integer          not null
#  platform :integer          not null
#  token    :string           not null
#


class FirebaseCloudMessagingToken < ApplicationRecord
  belongs_to :user, required: true

  enum platform: %i(iOS android)

  validates :user_id, uniqueness: { scope: :token }
  validates :platform, :token, presence: true
  validates :token, format: { with: /\A[a-zA-Z0-9_:\-]+\z/ }
end
