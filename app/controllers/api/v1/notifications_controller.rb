class Api::V1::NotificationsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def index
    notifications = current_user.notifications.order(created_at: :desc).paginate(page: params[:page])
    serialize_notifications = ActiveModelSerializers::SerializableResource.new(notifications,
        each_serializer: Api::V1::NotificationSerializer)
    render json: {total_page: notifications.total_pages, current_page: notifications.current_page, notifications: serialize_notifications}
  end

  def delete_notifications
    notifications = current_user.notifications.where(id: params[:ids])
    notifications.destroy_all
    render json: {success: true, message: "Notification successfully deleted"}
  end
end
