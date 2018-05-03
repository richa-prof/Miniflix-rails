class LoggedInUser < ApplicationRecord

  belongs_to :user
  before_save :logout_other_user

  def logout_other_user
    LoggedInUser.where(device_token: device_token).update_all(device_type: "",device_token:"",notification_from: "")
  end
end
