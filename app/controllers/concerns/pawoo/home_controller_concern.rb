# frozen_string_literal: true

module Pawoo::HomeControllerConcern
  extend ActiveSupport::Concern

  included do
    skip_before_action :store_current_location, if: :root_path?
  end

  private

  def root_path?
    request.fullpath == '/'
  end
end
