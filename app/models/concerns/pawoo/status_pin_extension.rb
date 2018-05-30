# frozen_string_literal: true

module Pawoo::StatusPinExtension
  extend ActiveSupport::Concern

  included do
    after_commit :pawoo_clear_cache
    after_destroy :pawoo_clear_cache
  end

  private

  def pawoo_clear_cache
    Rails.cache.delete(status.cache_key) if status
  end
end
