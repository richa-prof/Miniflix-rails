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
      user.sign_up_from = 'by_admin'
      Rails.logger.debug "=======Processing for user_id: #{user.id}======="
      puts "=======Processing for user_id: #{user.id}======="

      if user.save(validate: false)
        Rails.logger.debug "Successfully update user_id: #{user.id}"
        puts "Successfully update user_id: #{user.id}"
      else
        Rails.logger.debug "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
        puts "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
      end
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
        if user.save(validate: false)
          Rails.logger.debug "Successfully updated user_id: #{user.id}"
          puts "Successfully update user_id: #{user.id}"
        else
          Rails.logger.debug "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
          puts "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
        end

        count += 1
      end
    end
    Rails.logger.debug "<<<<<<<<< #{count} rows affected <<<<<<<<<"
    puts "<<<<<<<<< #{count} rows affected <<<<<<<<<"
  end

  def is_validate_phone_number? phone_number
    phone_number.phony_formatted(strict: true) ? true : false
  end

  desc "CSV file generate"
  task csv_file_generate: :environment do
    CSV.open("user_details.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'is_free', 'registration_plan', 'subscription_plan', 'provider', 'payment_method_available', 'customer_id', 'subscription_id', 'receipt_url']
      csv << column_names
      User.all.each do |user|
        csv << [user.id, user.email, user.name, user.sign_up_from, user.is_free, user.registration_plan, user.subscription_plan_status, user.provider, is_payment_method_available?(user), user.customer_id, user.subscription_id, is_receipt_url_present?(user)]
      end
    end
  end

  desc "CSV file generate where sign_up_from and register_plan  is nil"
  task csv_file_generate_1: :environment do
    CSV.open("user_details_with_sign_up_from_and_registration_plan_nil.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'is_free', 'registration_plan', 'subscription_plan', 'provider', 'payment_method_available', 'customer_id', 'subscription_id']
      csv << column_names
      User.all.each do |user|
        if((user.sign_up_from == nil or user.sign_up_from = '') and (user.registration_plan == nil or user.registration_plan = ''))
          puts "user: #{user.id}, sign_up_from: #{user.sign_up_from}, registration_plan: #{user.registration_plan}"
          csv << [user.id, user.email, user.name, user.sign_up_from, user.is_free, user.registration_plan, user.subscription_plan_status, user.provider, is_payment_method_available?(user), user.customer_id, user.subscription_id]
        end
      end
    end
  end

  desc "Update subscription_plan_status"
  task update_subscription_plan_status: :environment do

    users = User.Web.select{ |u| u if u.registration_plan.blank? }

    count = 0

    Rails.logger.debug "=======update subscription_plan_status from users======="

    users.each do |user|
      Rails.logger.debug "sign_up_from: #{user.sign_up_from}, registration_plan: #{user.registration_plan}"
      puts "sign_up_from: #{user.sign_up_from}, registration_plan: #{user.registration_plan}"
      Rails.logger.debug "=======Processing for user_id: #{user.id}======="
      puts "=======Processing for user_id: #{user.id}======="

      user.subscription_plan_status = :incomplete
      if user.save(validate: false)
        Rails.logger.debug "Successfully updated user_id #{user.id}"
        puts "Successfully updated user_id #{user.id}"
      else
        Rails.logger.debug "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
        puts "update failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
      end
      
      count += 1
    end 
    Rails.logger.debug "<<<<<<<<< #{count} rows Updated <<<<<<<<<"
    puts "<<<<<<<<< #{count} rows Updated<<<<<<<<<"
  end

  def is_payment_method_available?(user)
    user.user_payment_methods.blank? ? 'NA' : 'Yes'
  end

  def is_receipt_url_present?(user)
    if user.sign_up_from == 'iOS'
      puts user.receipt_data.present? ? 'Yes' : 'No'
      user.receipt_data.present? ? 'Yes' : 'No'
    else
      puts user.receipt_data.present? ? 'Yes' : '-'
      user.receipt_data.present? ? 'Yes' : '-'
    end
  end
end

# Commands to run the above tasks:
# 1. rake task_for_miniflix:update_sign_up_from
# 2. rake task_for_miniflix:update_subscription_plan_status
# 3. rake task_for_miniflix:validate_phone_number
