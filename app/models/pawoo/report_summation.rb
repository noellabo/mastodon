# frozen_string_literal: true
# == Schema Information
#
# Table name: pawoo_report_summations
#
#  id                 :bigint(8)        not null, primary key
#  date               :date             not null
#  total_count        :integer          default(0), not null
#  other_count        :integer          default(0), not null
#  prohibited_count   :integer          default(0), not null
#  reproduction_count :integer          default(0), not null
#  spam_count         :integer          default(0), not null
#  nsfw_count         :integer          default(0), not null
#  donotlike_count    :integer          default(0), not null
#

class Pawoo::ReportSummation < ApplicationRecord
  def self.build_summation(time)
    start = time.in_time_zone('Asia/Tokyo').beginning_of_day
    finish = start + 1.day
    total_count = 0

    summation = find_or_initialize_by(date: start.to_date)
    report_count = Report.select('pawoo_report_type, sum(COALESCE(array_length(status_ids, 1), 1)) as sum')
                         .where(created_at: (start..finish)).group(:pawoo_report_type)
                         .each_with_object({}) { |report, hash| hash[report.pawoo_report_type] = report.sum }

    Report.pawoo_report_types.keys.each do |report_type|
      count = report_count[report_type] || 0
      summation.send("#{report_type}_count=", count)
      total_count += count
    end

    summation.total_count = total_count
    summation
  end
end
