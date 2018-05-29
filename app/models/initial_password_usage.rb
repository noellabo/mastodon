# == Schema Information
#
# Table name: initial_password_usages
#
#  id      :integer          not null, primary key
#  user_id :integer          not null
#

class InitialPasswordUsage < ApplicationRecord
  belongs_to :user, required: true
  validates :user, uniqueness: true
end
