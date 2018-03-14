# frozen_string_literal: true

module Pawoo::StatusesControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :pawoo_set_container_classes, only: :show
  end

  def pawoo_set_container_classes
    @pawoo_container_classes = 'container pawoo-wide'
  end
end
