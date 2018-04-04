# frozen_string_literal: true

module Pawoo::FollowerAccountsControllerConcern
  extend ActiveSupport::Concern

  included { helper_method :pawoo_schema }

  private

  def pawoo_schema
    ActiveModelSerializers::SerializableResource.new(
      Pawoo::Schema::FollowerAccountsPagePresenter.new(account: @account),
      serializer: Pawoo::Schema::FollowerAccountsBreadcrumbListSerializer
    )
  end
end
