namespace :user_reset_password do
  desc 'Send reset password reminders to user'
  task send_reset_password_reminder: :environment do
    # Only need to send the `reminder` in production environment.
    if Rails.env.production?
      User.with_migrate_user.each do |user|
        SendResetPasswordReminderJob.perform_later(user.id)
      end
    end
  end
end
