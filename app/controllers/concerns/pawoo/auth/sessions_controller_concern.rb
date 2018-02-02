# frozen_string_literal: true

module Pawoo::Auth::SessionsControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :pawoo_set_current_user_has_oauth_authentication, only: [:destroy]
  end

  protected

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(*)
    if @pawoo_current_user_has_oauth_authentication && Rails.configuration.x.pixiv_endpoints[:www]
      template = Addressable::Template.new("#{Rails.configuration.x.pixiv_endpoints[:www]}/logout.php?return_to={return_to}")
      template.expand(return_to: root_url).to_s
    else
      super
    end
  end

  private

  def pawoo_set_current_user_has_oauth_authentication
    @pawoo_current_user_has_oauth_authentication = current_user.oauth_authentications.exists? if current_user
  end
end
