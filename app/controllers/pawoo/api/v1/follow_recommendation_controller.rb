# frozen_string_literal: true

class Pawoo::Api::V1::FollowRecommendationController < Api::BaseController
  # before_action -> { doorkeeper_authorize! :follow }
  # before_action :require_user!
  respond_to :json

  def index
    current_account_id = current_account.id
    follow_account_ids = Follow.where(account_id: current_account_id).select(:target_account_id)
    @recommend_follows = Follow.where(target_account_id: current_account_id, account_id: follow_account_ids).includes(:account).shuffle[0..4]
    render json: @recommend_follows.map(&:account), each_serializer: REST::AccountSerializer
  end
end