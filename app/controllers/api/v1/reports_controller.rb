# frozen_string_literal: true

class Api::V1::ReportsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, except: [:create]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create]
  before_action :require_user!

  respond_to :json

  def index
    @reports = current_account.reports
    render json: @reports, each_serializer: REST::ReportSerializer
  end

  def create
    @report = current_account.reports.create!(
      target_account: reported_account,
      status_ids: reported_status_ids,
      pawoo_report_type: report_params[:pawoo_report_type].presence || 'other',
      action_taken: true,
      pawoo_report_targets: pawoo_report_targets,
      comment: report_params[:comment]
    )

    # 管理者権限を持つ全てのアカウントにメールが送信されるため一旦無効化
    # User.staff.includes(:account).each { |u| AdminMailer.new_report(u.account, @report).deliver_later }

    render json: @report, serializer: REST::ReportSerializer
  end

  private

  def reported_status_ids
    @reported_status_ids ||= Status.find(status_ids).pluck(:id)
  end

  def status_ids
    Array(report_params[:status_ids])
  end

  def reported_account
    @reported_account ||= Account.find(report_params[:account_id])
  end

  def pawoo_report_targets
    if reported_status_ids.present?
      resolved_target_ids = Pawoo::ReportTarget.where(state: :resolved, target_type: 'Status', target_id: reported_status_ids).distinct(:target_id).pluck(:target_id).to_set
      reported_status_ids.map do |status_id|
        state = resolved_target_ids.include?(status_id) ? :resolved : :unresolved
        Pawoo::ReportTarget.new(target_type: 'Status', target_id: status_id, state: state)
      end
    else
      [Pawoo::ReportTarget.new(target: reported_account)]
    end
  end

  def report_params
    params.permit(:account_id, :comment, :pawoo_report_type, status_ids: [])
  end
end
