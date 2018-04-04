# frozen_string_literal: true

module Pawoo::StatusesControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :pawoo_set_container_classes, only: :show
    helper_method :pawoo_schema
  end

  def pawoo_schema
    ActiveModelSerializers::SerializableResource.new(
      Pawoo::Schema::StatusPagePresenter.new(account: @account, status: @status),
      serializer: Pawoo::Schema::StatusBreadcrumbListSerializer
    )
  end

  def pawoo_set_container_classes
    @pawoo_container_classes = 'container pawoo-wide'
  end
end
