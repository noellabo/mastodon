# frozen_string_literal: true

class Pawoo::Admin::OauthAuthenticationsController < Admin::BaseController
  before_action :set_oauth_authentication

  def destroy
    if @oauth_authentication.force_destroy
      flash[:notice] = t('oauth_authentications.successfully_unlinked')
    else
      flash[:alert] = t('oauth_authentications.failed_linking')
    end

    redirect_to admin_account_path(@oauth_authentication.user.account_id)
  end

  private

  def set_oauth_authentication
    @oauth_authentication = OauthAuthentication.find(params[:id])
  end
end
