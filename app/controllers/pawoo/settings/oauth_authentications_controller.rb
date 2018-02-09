# frozen_string_literal: true

class Pawoo::Settings::OauthAuthenticationsController < ApplicationController
  PIXIV_URL = Addressable::Template.new('https://www.pixiv.net/oauth/revoke/?code={code}&pixiv_user_id={uid}')

  layout 'admin'

  before_action :authenticate_user!
  before_action :reject_initial_password_usage, only: [:destroy]
  before_action :set_oauth_authentication, only: [:destroy]

  def index; end

  def destroy
    if @oauth_authentication.destroy
      url = PIXIV_URL.expand(
        code: Rails.application.secrets.oauth[:pixiv][:key],
        uid: @oauth_authentication.uid
      )

      redirect_to(url.to_s)
    else
      redirect_to({ action: :index }, alert: t('oauth_authentications.failed_linking'))
    end
  end

  private

  def reject_initial_password_usage
    redirect_to action: :index if current_user.initial_password_usage
  end

  def set_oauth_authentication
    @oauth_authentication = current_user.oauth_authentications.find(params[:id])
  end
end
