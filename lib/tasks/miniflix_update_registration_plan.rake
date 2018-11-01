namespace :miniflix do
  desc "Update registration_plan if it is blank"
  task update_registration_plan: :environment do

    users = User.select{ |u| u if u.registration_plan.blank? }

    count = 0

    Rails.logger.debug "=======update registration_plan from users======="

    users.each do |user|
      Rails.logger.debug "sign_up_from: #{user.sign_up_from}, registration_plan: #{user.registration_plan}"
      puts "sign_up_from: #{user.sign_up_from}, registration_plan: #{user.registration_plan}"
      Rails.logger.debug "=======Processing for user_id: #{user.id}======="
      puts "=======Processing for user_id: #{user.id}======="

      if user.user?
        user.subscription_plan_status = User.subscription_plan_statuses['incomplete']
        user.registration_plan = User.registration_plans['Monthly']
        save_record(user)
        count += 1
      end
    end
    Rails.logger.debug "<<<<<<<<< #{count} rows Updated <<<<<<<<<"
    puts "<<<<<<<<< #{count} rows Updated<<<<<<<<<"
  end

  def save_record(user)
    if user.save(validate: false)
      Rails.logger.debug "Successfully updated user_id #{user.id}"
      puts "Successfully updated user_id #{user.id}"
    else
      Rails.logger.debug "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
      puts "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
    end
  end
end

# RAILS_ENV=production bundle exec rake miniflix:update_registration_plan
