# frozen_string_literal: true

class Pawoo::OauthAuthenticationsController < ApplicationController
  before_action :set_account

  def show
    redirect_to short_account_path(@account)
  end

  private

  def set_account
    @oauth_authentication = OauthAuthentication.find_by!(provider: 'pixiv', uid: params[:uid])
    @account = @oauth_authentication.user.account
  end
end
