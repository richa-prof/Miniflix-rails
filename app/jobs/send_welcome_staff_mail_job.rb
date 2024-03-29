class SendWelcomeStaffMailJob < ApplicationJob
  queue_as :default

  def perform(staff_id)
    staff = User.find(staff_id)
    staff.send_welcome_mail
  end
end
