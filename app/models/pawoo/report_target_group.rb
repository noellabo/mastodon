# frozen_string_literal: true

class Pawoo::ReportTargetGroup
  include ActiveModel::Model

  attr_accessor :report_targets, :account, :status

  def account_pixiv_uid
    account&.oauth_authentications&.first&.uid
  end

  def target_type
    status.nil? ? 'Account' : 'Status'
  end

  def target_id
    status&.id || account.id
  end
end
