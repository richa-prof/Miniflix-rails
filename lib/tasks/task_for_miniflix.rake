namespace :task_for_miniflix do
  desc "Update the user's sign_up_from field to by_admin if it's nil or blank."
  task update_sign_up_from: :environment do
    # begin
    #   @con = Mysql2::Client.new(:host => "localhost", 
    #                            :username => "root", 
    #                            :password => "root",
    #                            :database => "database_1"
    #                            )   
    #   @con.query "UPDATE users SET sign_up_from = 'by_admin' WHERE sign_up_from is NULL or sign_up_from = ''"
    #   puts "The query has affected #{@con.affected_rows} rows" 
    # rescue Mysql::Error => e
    #   puts e
    # ensure
    #   @con.close if @con
    # end
    count = 0

    users = User.all.select{ |u| u if u.sign_up_from.blank? }

    users.each do |user|
      user.sign_up_from = User.sign_up_froms['by_admin']
      Rails.logger.debug "=======Processing for user_id: #{user.id}======="
      puts "=======Processing for user_id: #{user.id}======="
      save_record(user)
      count += 1
    end

    Rails.logger.debug "<<<<<<<<< #{count} rows affected <<<<<<<<<"
    puts "<<<<<<<<< #{count} rows affected <<<<<<<<<"
  end

  desc "Update the user's phone_number field to nil if it's not a valid phone_number with phony_formatted."
  task validate_phone_number: :environment do
    count = 0
    users = User.where.not(phone_number: nil)
    Rails.logger.debug "=======validate phone_number from users======="

    users.each do |user|
      unless is_validate_phone_number?(user.phone_number)
        Rails.logger.debug "=======update for #{user.id} if phone_number is invalid======="
        user.phone_number = nil
        save_record(user)
        count += 1
      end
    end
    Rails.logger.debug "<<<<<<<<< #{count} rows affected <<<<<<<<<"
    puts "<<<<<<<<< #{count} rows affected <<<<<<<<<"
  end

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

      if user.Web?
        user.subscription_plan_status = User.subscription_plan_statuses['incomplete']
        user.registration_plan = User.registration_plans['monthly']
        save_record(user)
      elsif user.Android?
        user.registration_plan = User.registration_plans['Freemium']
        save_record(user)
      end
      count += 1
    end 
    Rails.logger.debug "<<<<<<<<< #{count} rows Updated <<<<<<<<<"
    puts "<<<<<<<<< #{count} rows Updated<<<<<<<<<"
  end

  def is_validate_phone_number? phone_number
    phone_number.phony_formatted(strict: true) ? true : false
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

# Commands to run the above tasks:
# 1. rake task_for_miniflix:update_sign_up_from
# 2. rake task_for_miniflix:update_registration_plan
# 3. rake task_for_miniflix:validate_phone_number

# Currently we are saving the users with `(validate: false)` beacuse there are some errors in different different fields. Need to fix all those problems.

# For example an error is there: ["Friendly is reserved"]
# Root cause: These are the reserved_words from FriendlyId.
# config.reserved_words = %w(new edit index session login logout users admin stylesheets assets javascripts images)
# Need to fix this.
# Ref.: https://github.com/norman/friendly_id

# Note: To find invalid_users
# invalid_users = User.all.reject(&:valid?)
# invalid_users.count
# invalid_users.map{|u| u.errors.full_messages}
