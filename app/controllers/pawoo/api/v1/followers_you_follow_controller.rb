# frozen_string_literal: true

class Pawoo::Api::V1::FollowersYouFollowController < Api::BaseController
  # before_action -> { doorkeeper_authorize! :follow }
  # before_action :require_user!
  respond_to :json

  def show
    target_user_id = params[:user_id].to_i
    current_account_id = current_account.id
    return render json: [] if target_user_id == current_account_id
    target_followers = Follow.where(target_account_id: target_user_id).select(:account_id)
    @followers_you_follow = Follow.where(account_id: current_account_id, target_account_id: target_followers).preload(:target_account)
    render json: @followers_you_follow.map(&:target_account), each_serializer: REST::AccountSerializer
  end
end
