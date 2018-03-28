# frozen_string_literal: true

class Pawoo::Admin::ReportSummationsController < Admin::BaseController
  def index
    date = params[:date] ? Time.zone.parse(params[:date]) : Time.zone.now
    @start = date.beginning_of_month
    finish = @start.next_month
    @report_summations = Pawoo::ReportSummation.where('date >= ? AND date < ?', @start.to_date, finish.to_date).order(:date)

    @report_types = Report.pawoo_report_types.keys
    @summation_by_month = @report_types.map { |report_type| [report_type, 0] }.to_h
    @summation_by_month['total'] = 0

    @report_summations.each do |report_summation|
      @report_types.each do |report_type|
        count = report_summation.send("#{report_type}_count")
        @summation_by_month[report_type] += count
        @summation_by_month['total'] += count
      end
    end
  end
end
