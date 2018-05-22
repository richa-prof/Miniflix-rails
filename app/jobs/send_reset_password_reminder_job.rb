class SendResetPasswordReminderJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    if user.phone_number.present?
      user.send_reset_password_reminder_sms
    end

    if user.email? && user.Web?
      user.send_reset_password_reminder_email
    elsif user.iOS? || user.Android?
      user.send_reset_password_reminder_push_notification
    end
  end
end
