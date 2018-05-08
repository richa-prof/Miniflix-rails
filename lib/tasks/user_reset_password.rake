namespace :user_reset_password do
  desc 'Send reset password reminders to user'
  task send_reset_password_reminder: :environment do
    # Only need to send the `reminder` in production environment.
    SendResetPasswordReminderJob.perform_later if Rails.env.production?
  end
end
