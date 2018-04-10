class SubscriptionStatusChangeJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.user.find user_id
    puts "#{user.id} under job queue"
    user.expired! if user.trial? && user.Annually?
  end
end
