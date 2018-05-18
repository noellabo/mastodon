# frozen_string_literal: true

class Pawoo::Admin::ReportTargetsController < Admin::BaseController
  REPORT_TARGETS_LIMIT = 30

  def index
    authorize Pawoo::ReportTarget, :index?

    target_statuses = Set.new
    target_accounts = Set.new

    # すべて取得して通報の多い順並べる
    report_targets_ids = Pawoo::ReportTarget.where(state: state_param).group([:target_type, :target_id]).count.sort_by { |_, count| -count }.map(&:first)
    @report_target_count = report_targets_ids.size

    @current_page = params[:page].to_i < 1 ? 1 : params[:page].to_i
    @first_page = 1
    @last_page = (@report_target_count.to_f / REPORT_TARGETS_LIMIT).ceil
    @prev_page = @current_page > 1 ? @current_page - 1 : nil
    @next_page = @current_page * REPORT_TARGETS_LIMIT < @report_target_count ? @current_page + 1 : nil

    report_targets_ids = report_targets_ids.drop((@current_page - 1) * REPORT_TARGETS_LIMIT).take(REPORT_TARGETS_LIMIT)
    report_targets_ids.each do |target_type, target_id|
      target_statuses.add(target_id) if target_type == 'Status'
      target_accounts.add(target_id) if target_type == 'Account'
    end

    report_target_groups_map = load_report_target_groups_map(target_statuses.to_a, target_accounts.to_a, state_param)
    @report_target_groups = report_targets_ids.map do |target_type, target_id|
      report_target_groups_map[target_type][target_id]
    end
  end

  def create
    authorize Pawoo::ReportTarget, :create?
    form = Pawoo::Form::ReportTargetGroup.new(report_target_groups_params: params.require(:report_target_groups), current_account: current_account)

    if form.save
      flash[:notice] = I18n.t('pawoo.admin.report_targets.success_msg')
    else
      flash[:alert] = I18n.t('pawoo.admin.report_targets.failed_msg')
    end

    next_params = state_param == :pending ? { pending: '1' } : {}
    redirect_to admin_pawoo_report_targets_path(next_params)
  end

  private

  def state_param
    @state_param ||= params[:pending] == '1' ? :pending : :unresolved
  end

  def load_report_target_groups_map(target_statuses, target_accounts, state)
    report_target_groups_map = { 'Account' => {}, 'Status' => {} }

    report_targets_for_status_of = Pawoo::ReportTarget.where(state: state, target_type: 'Status', target_id: target_statuses).preload(:report).group_by(&:target_id)
    Status.where(id: target_statuses).preload(:mentions, :media_attachments, :pixiv_cards, account: :oauth_authentications).map do |status|
      report_target_groups_map['Status'][status.id] = Pawoo::ReportTargetGroup.new(status: status, account: status.account, report_targets: report_targets_for_status_of[status.id])
    end

    report_targets_for_account_of = Pawoo::ReportTarget.where(state: state, target_type: 'Account', target_id: target_accounts).preload(:report).group_by(&:target_id)
    Account.where(id: target_accounts).preload(:oauth_authentications).map do |account|
      report_target_groups_map['Account'][account.id] = Pawoo::ReportTargetGroup.new(account: account, report_targets: report_targets_for_account_of[account.id])
    end

    report_target_groups_map
  end
end
