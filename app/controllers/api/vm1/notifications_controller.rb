class Api::Vm1::NotificationsController < Api::Vm1::ApplicationController
  before_action :authenticate_api, only: [:get_notifications, :delete_notifications, :mark_notification]
  protect_from_forgery with: :null_session, only: :mark_unread_notifications
  def get_notifications
    notifications = api_user.notifications.order(created_at: :desc).offset(params[:offset]).limit(params[:limit])
    if notifications.present?
      api_response = {code: "0", status: "Success", message: "notifications", notification: notifications.as_json}
    else
      api_response = { code: "0", status: "Success", message: "notifications not found.", notification: []}
    end
    render json: api_response
  end


  def delete_notifications
    begin
      api_user.notifications.where(id: params[:notification_ids].split(',')).destroy_all
      api_response = {code: "0", status: "success", message: "Notification Destroyed"}
    rescue Exception => e
      api_response = {code: "-1", status: "Error", message => e.message}
    end
    render :json=> api_response
  end

  def send_test_notification
    begin
      if params[:token].present? && params[:device].present?
        Notification.test_notification(params[:token],params[:device])
        @response = {:code => "0",:status => "success",:msg => "Notification sent"}
      else
        @response = {:code => "1",:status => "success",:msg => "Please pass notification token/ device"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:msg => e.message}
    end
    render :json=> @response
  end

  def mark_notification
    user = User.find(params[:user_id])
    notification = user.notifications.find(params[:notification_id])
    if notification
      notification.update!(is_read: true)
      response = {:code => "0",:status => "success",:message => "Notification marked as read!", notification: notification.as_json}
    else
      response = {:code => "0",:status => "success",:message => "Not found in list of your notifications!", notification: []}
    end
    render :json => response
  end

  def mark_unread_notifications
    user = User.find(params[:user_id])
    if user
      user.notifications.each do |notification|
        notification.update!(is_read: false)
      end
      response = {:code => "0",:status => "success",:message => "Notification marked as unread!", notification: user.notifications.as_json}
      render :json => response
    else
      response = {:code => "0",:status => "success", :message => "Not found!", notification: []}
    end
    render :json => response
  end
end
