# frozen_string_literal: true

module Pawoo::AccountsControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :pawoo_set_container_classes
    helper_method :pawoo_next_url, :pawoo_prev_url, :pawoo_suggestion_strip_props, :pawoo_schema
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

  def pawoo_suggestion_strip_props
    accounts = Account.where(id: Redis.current.smembers('pawoo:publicly_suggested_accounts')).shuffle
    media_attachments_of = Pawoo::LoadAccountMediaAttachmentsService.new.call(accounts, 3)

    {
      locale: I18n.locale,
      accounts: ActiveModelSerializers::SerializableResource.new(accounts, each_serializer: REST::SuggestedAccountSerializer, media_attachments_of: media_attachments_of).as_json,
      tags: ActiveModelSerializers::SerializableResource.new(TrendTag.find_tags(5), each_serializer: REST::TrendTagSerializer).as_json,
    }
  end

  def pawoo_schema
    presenter = Pawoo::Schema::AccountPagePresenter.new(
      account: @account,
      statuses: params[:page].to_i.zero? ? @pinned_statuses + @statuses_collection : @statuses_collection
    )

    [
      ActiveModelSerializers::SerializableResource.new(
        presenter,
        serializer: Pawoo::Schema::AccountBreadcrumbListSerializer
      ),

      ActiveModelSerializers::SerializableResource.new(
        presenter,
        serializer: Pawoo::Schema::AccountItemListSerializer
      )
    ]
  end

  def pawoo_set_container_classes
    @pawoo_container_classes = 'container pawoo-wide'
  end
end
