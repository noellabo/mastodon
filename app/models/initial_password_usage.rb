# == Schema Information
#
# Table name: initial_password_usages
#
#  id      :bigint(8)        not null, primary key
#  user_id :bigint(8)        not null
#

class InitialPasswordUsage < ApplicationRecord
  belongs_to :user, required: true
  validates :user, uniqueness: true
end
