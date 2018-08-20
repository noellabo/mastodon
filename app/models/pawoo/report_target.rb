# frozen_string_literal: true
# == Schema Information
#
# Table name: pawoo_report_targets
#
#  id          :bigint(8)        not null, primary key
#  report_id   :bigint(8)        not null
#  target_type :string           not null
#  target_id   :bigint(8)        not null
#  state       :integer          default("unresolved"), not null
#

class Pawoo::ReportTarget < ApplicationRecord
  belongs_to :report
  belongs_to :target, polymorphic: true

  belongs_to :account, foreign_type: 'Account', foreign_key: 'target_id', optional: true
  belongs_to :status, foreign_type: 'Status', foreign_key: 'target_id', optional: true

  enum state: %i(unresolved pending resolved)

  scope :filter_status_by_account, ->(account_ids) { where(target_type: 'Status').joins(status: :account).where(statuses: { account: account_ids }) }
end
