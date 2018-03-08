# frozen_string_literal: true
# == Schema Information
#
# Table name: pawoo_expo_push_tokens
#
#  id      :integer          not null, primary key
#  user_id :integer          not null
#  token   :string           not null
#

class Pawoo::ExpoPushToken < ApplicationRecord
  belongs_to :user, required: true

  validates :user_id, uniqueness: { scope: :token }
  validates :token, format: { with: /\AExponentPushToken\[[a-zA-Z0-9_:\-]+\]\z/ }
end
