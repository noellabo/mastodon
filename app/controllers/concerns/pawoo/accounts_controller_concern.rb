# frozen_string_literal: true

module Pawoo::AccountsControllerConcern
  extend ActiveSupport::Concern

  included do
    helper_method :pawoo_next_url, :pawoo_prev_url
  end

  private

  def pawoo_statuses_from_pinned_status
    @pawoo_statuses_from_pinned_status ||= @account.pinned_statuses.published
  end

  def pawoo_next_url
    next_page = @statuses.current_page + 1

    if media_requested?
      short_account_media_url(@account, page: next_page)
    elsif replies_requested?
      short_account_with_replies_url(@account, page: next_page)
    else
      short_account_url(@account, page: next_page)
    end
  end

  def pawoo_prev_url
    prev_page = @statuses.current_page - 1
    prev_page = nil if prev_page == 1

    if media_requested?
      short_account_media_url(@account, page: prev_page)
    elsif replies_requested?
      short_account_with_replies_url(@account, page: prev_page)
    else
      short_account_url(@account, page: prev_page)
    end
  end
end
