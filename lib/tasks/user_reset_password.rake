namespace :user_reset_password do
  desc 'Send reset password reminders to user'
  task send_reset_password_reminder: :environment do
    SendResetPasswordReminderJob.perform_later
  end
end
