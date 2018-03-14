class Api::V1::UserEmailNotificationsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def index
    user_email_notification = current_user.user_email_notification
    email_notification_serializer = ActiveModelSerializers::SerializableResource.new(user_email_notification, serializer: Api::V1::UserEmailNotificationSerializer).serializable_hash
    render json: {success: true, user_email_notification: email_notification_serializer}
  end

  def update
    user_email_notification = current_user.user_email_notification
    if user_email_notification.update_attributes(user_email_notification_update_params)
      response = {success: true, message: "successful email Notification updated"}
    else
      response = {success: false, message: user_email_notification.errors}
    end
    render json: response
  end

  private
    def user_email_notification_update_params
      params.require(:user_email_notification).permit(:product_updates,:films_added, :special_offers_and_promotions, :better_product, :do_not_send)
    end

end
