class LoggedInUser < ApplicationRecord

  belongs_to :user
  before_save :logout_other_user

  # CONSTANTS
  DEVICE_TYPE_ANDROID = 'Android'
  DEVICE_TYPE_IOS = 'iOS'

  def logout_other_user
    LoggedInUser.where(device_token: device_token).update_all(device_type: "",device_token:"",notification_from: "")
  end
end
