# frozen_string_literal: true

class Pawoo::Api::V1::FirebaseCloudMessagingTokensController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write }, only:  [:create]
  before_action :require_user!

  def create
    @firebase_cloud_messaging_token = current_user.firebase_cloud_messaging_tokens.find_or_initialize_by(
      firebase_cloud_messaging_token_params
    )

    if @firebase_cloud_messaging_token.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    firebase_cloud_messaging_token = current_user.firebase_cloud_messaging_tokens.find_by!(firebase_cloud_messaging_token)

    if firebase_cloud_messaging_token.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def firebase_cloud_messaging_token_params
    params.require(:firebase_cloud_messaging_token).permit(
      :token, :platform
    )
  end
end
