class StatusPagination
  attr_reader :status

  def initialize(status, target_account = nil)
    @status = status
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
      @status.account.statuses, # アカウントのステータス
      Status.without_reblogs,   # ブーストは含まない
      permitted_statuses,       # 閲覧権限がある
      without_tree_path,        # 現在のステータスのリプライは含まない(すでに同じページ内で表示されているため)
    ].compact.inject(&:merge)
  end

  def id
    Status.arel_table[:id]
  end

  def permitted_statuses
    Status.permitted_for(@status.account, @target_account)
  end

  def without_tree_path
    Status.where.not(id: ancestor_and_descendant_ids)
  end

  def ancestor_and_descendant_ids
    @ancestor_and_descendant_ids ||= @status.ancestors.map(&:id) + @status.descendants.map(&:id)
  end
end
