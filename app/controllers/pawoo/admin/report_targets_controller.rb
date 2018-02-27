# frozen_string_literal: true

class Pawoo::Admin::ReportTargetsController < Admin::BaseController
  REPORT_TARGETS_LIMIT = 20

  def index
    authorize Pawoo::ReportTarget, :index?

    target_statuses = Set.new
    target_accounts = Set.new

    # 多めに通報対象を取得
    report_targets_ids = Pawoo::ReportTarget.where(state: state_param).order(id: :desc).limit(REPORT_TARGETS_LIMIT * 2).pluck(:target_type, :target_id)
    report_targets_ids.each do |target_type, target_id|
      target_statuses.add(target_id) if target_type == 'Status'
      target_accounts.add(target_id) if target_type == 'Account'
      break if target_statuses.size + target_accounts.size == REPORT_TARGETS_LIMIT
    end

    @report_target_groups = load_report_target_groups(target_statuses.to_a, target_accounts.to_a, state_param)
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

  def load_report_target_groups(target_statuses, target_accounts, state)
    report_target_groups = []

    report_targets_for_status_of = Pawoo::ReportTarget.where(state: state, target_type: 'Status', target_id: target_statuses).preload(:report).group_by(&:target_id)
    report_target_groups += Status.where(id: target_statuses).preload(:mentions, :media_attachments, :pixiv_cards, account: :oauth_authentications).map do |status|
      Pawoo::ReportTargetGroup.new(status: status, account: status.account, report_targets: report_targets_for_status_of[status.id])
    end

    report_targets_for_account_of = Pawoo::ReportTarget.where(state: state, target_type: 'Account', target_id: target_accounts).preload(:report).group_by(&:target_id)
    report_target_groups += Account.where(id: target_accounts).preload(:oauth_authentications).map do |account|
      Pawoo::ReportTargetGroup.new(account: account, report_targets: report_targets_for_account_of[account.id])
    end

    report_target_groups
  end
end
