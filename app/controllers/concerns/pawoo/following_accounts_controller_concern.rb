# frozen_string_literal: true

module Pawoo::FollowingAccountsControllerConcern
  extend ActiveSupport::Concern

  included { helper_method :pawoo_schema }

  private

  def pawoo_schema
    ActiveModelSerializers::SerializableResource.new(
      Pawoo::Schema::FollowingAccountsPagePresenter.new(account: @account),
      serializer: Pawoo::Schema::FollowingAccountsBreadcrumbListSerializer
    )
  end
end
