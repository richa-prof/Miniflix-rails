class LoggedInUser < ApplicationRecord

  belongs_to :user
  before_save :logout_other_user

  # CONSTANTS
  DEVICE_TYPE_ANDROID = 'Android'
  DEVICE_TYPE_IOS = 'iOS'

  # SCOPE STARTS
  scope :with_user_ids, -> (user_ids){ where(user_id: user_ids) }
  scope :with_device_type_ios, -> { where("lower(device_type) = ? AND lower(notification_from) = ? ",'iOS', ENV['IOS_MODE']) }
  scope :with_device_type_android, -> { where("lower(device_type) = ?",'android') }

  # ===== Class methods START =====
  class << self
    def ios_user_development_tokens(user_ids)
      with_user_ids(user_ids).with_device_type_ios.pluck(:device_token)
    end

    def android_user_tokens(user_ids)
      with_user_ids(user_ids).with_device_type_android.pluck(:device_token)
    end
  end
  # ===== Class methods END =====

  def logout_other_user
    LoggedInUser.where(device_token: device_token).update_all(device_type: "", device_token:"", notification_from: "")
  end
end
