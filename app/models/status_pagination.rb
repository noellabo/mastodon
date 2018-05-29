class StatusPagination
  attr_reader :status

  def initialize(status, scope, target_account = nil)
    @status = status
    @scope = scope
    @target_account = target_account
  end

  def next
    @next ||= statuses.where(id.gt(@status.id)).last
  end

  def previous
    @previous ||= statuses.where(id.lt(@status.id)).first
  end

  private

  def statuses
    @statuses ||= [
      @scope,
      @status.account.statuses, # アカウントのステータス
      Status.without_reblogs,   # ブーストは含まない
      permitted_statuses,       # 閲覧権限がある
    ].compact.inject(&:merge)
  end

  def id
    Status.arel_table[:id]
  end

  def permitted_statuses
    Status.permitted_for(@status.account, @target_account)
  end
end
