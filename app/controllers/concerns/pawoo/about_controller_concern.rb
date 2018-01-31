# frozen_string_literal: true

module Pawoo::AboutControllerConcern
  extend ActiveSupport::Concern

  included do
    with_options only: :show do
      skip_before_action :store_current_location
      before_action :pawoo_authenticate_no_user
    end
  end

  def app_terms; end

  def app_eula; end

  private

  def pawoo_authenticate_no_user
    redirect_to root_url if user_signed_in?
  end
end
