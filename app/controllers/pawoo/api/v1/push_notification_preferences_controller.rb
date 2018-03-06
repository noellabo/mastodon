# frozen_string_literal: true

class Pawoo::Api::V1::PushNotificationPreferencesController < Api::BaseController
  layout 'admin'
  respond_to :json

  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!
  before_action :set_settings

  def show
    render json: @settings, serializer: REST::PushNotificationPreferenceSerializer
  end

  def update
    user_settings.update(user_settings_params.to_h)

    if current_user.save
      render json: @settings, serializer: REST::PushNotificationPreferenceSerializer
    else
      render json: { error: current_user.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  private

  def set_settings
    @settings = current_user.settings
  end

  def user_settings
    UserSettingsDecorator.new(current_user)
  end

  def user_settings_params
    params.require(:user).permit(
      notification_firebase_cloud_messagings: %i(follow follow_request reblog favourite mention),
      notification_pawoo_expo_pushes: %i(follow follow_request reblog favourite mention),
      interactions: %i(must_be_follower must_be_following must_be_following_dm)
    )
  end
end
