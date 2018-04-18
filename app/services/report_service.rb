# frozen_string_literal: true

class ReportService < BaseService
  def call(source_account, target_account, options = {})
    @source_account = source_account
    @target_account = target_account
    @status_ids     = options.delete(:status_ids) || []
    @comment        = options.delete(:comment) || ''
    @options        = options

    create_report!

    # 管理者権限を持つ全てのアカウントにメールが送信されるため一旦無効化
    # notify_staff!

    forward_to_origin! if !@target_account.local? && ActiveModel::Type::Boolean.new.cast(@options[:forward])

    @report
  end

  private

  def create_report!
    @report = @source_account.reports.create!(
      target_account: @target_account,
      status_ids: @status_ids,
      comment: @comment,
      action_taken: true,
      pawoo_report_type: @options[:pawoo_report_type],
      pawoo_report_targets: pawoo_report_targets
    )
  end

  def notify_staff!
    User.staff.includes(:account).each do |u|
      AdminMailer.new_report(u.account, @report).deliver_later
    end
  end

  def forward_to_origin!
    ActivityPub::DeliveryWorker.perform_async(
      payload,
      some_local_account.id,
      @target_account.inbox_url
    )
  end

  def payload
    Oj.dump(ActiveModelSerializers::SerializableResource.new(
      @report,
      serializer: ActivityPub::FlagSerializer,
      adapter: ActivityPub::Adapter,
      account: some_local_account
    ).as_json)
  end

  def some_local_account
    @some_local_account ||= Account.local.where(suspended: false).first
  end

  def pawoo_report_targets
    if @status_ids.present?
      resolved_target_ids = Pawoo::ReportTarget.where(state: :resolved, target_type: 'Status', target_id: @status_ids).distinct(:target_id).pluck(:target_id).to_set
      @status_ids.map do |status_id|
        state = resolved_target_ids.include?(status_id) ? :resolved : :unresolved
        Pawoo::ReportTarget.new(target_type: 'Status', target_id: status_id, state: state)
      end
    else
      [Pawoo::ReportTarget.new(target: @target_account)]
    end
  end
end
