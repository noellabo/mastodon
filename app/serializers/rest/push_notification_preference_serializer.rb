# frozen_string_literal: true

class REST::PushNotificationPreferenceSerializer < ActiveModel::Serializer
  attributes :notification_firebase_cloud_messagings, :notification_pawoo_expo_pushes, :interactions

  def notification_firebase_cloud_messagings
    object['notification_firebase_cloud_messagings']
  end

  def notification_pawoo_expo_pushes
    object['notification_pawoo_expo_pushes']
  end

  def interactions
    object['interactions']
  end
end
