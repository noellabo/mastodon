# frozen_string_literal: true

module Pawoo::Api::V1::Statuses::PinsControllerConcern
  extend ActiveSupport::Concern

  included do
    after_action :pawoo_clear_cache
  end

  private

  def pawoo_clear_cache
    Rails.cache.delete(@status.cache_key)
  end
end
