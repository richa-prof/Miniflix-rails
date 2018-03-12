class Api::V1::UserEmailNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    user_email_notification = current_user.user_email_notification
    email_notification_serializer = ActiveModelSerializers::SerializableResource.new(user_email_notification, serializer: Api::V1::UserEmailNotificationSerializer).serializable_hash
    render json: {success: true, user_email_notification: email_notification_serializer}
  end
end
