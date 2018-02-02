# frozen_string_literal: true

module Pawoo::Api::V1::StatusesControllerConcern
  extend ActiveSupport::Concern

  private

  def pawoo_published
    published = status_params[:published]

    if published.nil?
      nil
    else
      begin
        DateTime.parse published
      rescue ArgumentError
        raise Mastodon::ValidationError
      end
    end
  end
end
