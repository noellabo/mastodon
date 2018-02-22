# frozen_string_literal: true
# == Schema Information
#
# Table name: pawoo_report_targets
#
#  id          :integer          not null, primary key
#  report_id   :integer          not null
#  target_type :string           not null
#  target_id   :integer          not null
#  state       :integer          default("unresolved"), not null
#

class Pawoo::ReportTarget < ApplicationRecord
  belongs_to :report
  belongs_to :target, polymorphic: true

  enum state: %i(unresolved pending resolved)
end
