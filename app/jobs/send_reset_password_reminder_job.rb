class SendResetPasswordReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.send_reset_password_reminder
  end
end
