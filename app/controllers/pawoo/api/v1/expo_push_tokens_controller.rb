# frozen_string_literal: true

class Pawoo::Api::V1::ExpoPushTokensController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  def create
    expo_push_token = current_user.expo_push_tokens.find_or_initialize_by(token: params[:token])
    if expo_push_token.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    expo_push_token = current_user.expo_push_tokens.find_by!(token: params[:token])
    if expo_push_token.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
