namespace :analyse_users do
  desc "analyse DB users"
  task generate_users_detailed_csv_file: :environment do
    CSV.open("tmp/detailed_users_list.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'is_free', 'registration_plan', 'subscription_plan', 'payment_method_available', 'customer_id', 'subscription_id', 'receipt_url', 'total_amount_paid', 'registration_date', 'provider', 'suspicious']
      csv << column_names
      User.find_each do |user|
        csv << [user.id, user.email, user.name, user.sign_up_from, is_free?(user), user.registration_plan, user.subscription_plan_status, is_payment_method?(user), user.customer_id, user.subscription_id, is_receipt_url?(user), total_paid_amount(user), registration_date(user), user.provider, '']
      end
    end
  end

  task generate_suspicious_users_detailed_csv_file: :environment do
    CSV.open("tmp/detailed_suspicious_users_list.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'registration_plan', 'subscription_plan', 'payment_method_available', 'customer_id', 'subscription_id', 'receipt_url', 'total_amount_paid', 'registration_date', 'provider', 'is_free', 'suspicious']
      csv << column_names

      invalid_users.each do |user|
        csv << [user.id, user.email, user.name, user.sign_up_from, user.registration_plan, user.subscription_plan_status, is_payment_method?(user), user.customer_id, user.subscription_id, is_receipt_url?(user), total_paid_amount(user), registration_date(user), user.provider, is_free?(user), '']
      end
    end
  end

  task generate_filtered_suspicious_users_detailed_csv_file: :environment do
    CSV.open("tmp/detailed_filtered_suspicious_users_list.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'registration_plan', 'subscription_plan', 'payment_method_available', 'customer_id', 'subscription_id', 'receipt_url', 'total_amount_paid', 'registration_date', 'provider', 'is_free', 'suspicious']
      csv << column_names

      invalid_users_without_transactions.each do |user|
        csv << [user.id, user.email, user.name, user.sign_up_from, user.registration_plan, user.subscription_plan_status, is_payment_method?(user), user.customer_id, user.subscription_id, is_receipt_url?(user), total_paid_amount(user), registration_date(user), user.provider, is_free?(user), '']
      end
    end
  end

  task set_subscription_plan_status_to_expired_for_invalid_users_without_transactions: :environment do
    user_logger = Logger.new("#{Rails.root}/log/suspicious_users_operation.log")

    target_users = invalid_users_without_transactions

    user_logger.debug ">>>>>>>>>>> Total invalid_users_without_transactions users:: #{target_users.count} >>>>>"
    puts ">>>>>>>>>>> Total invalid_users_without_transactions users:: #{target_users.count} >>>>>"
    @count = 0

    target_users.each do |user|

      user_logger.debug ">>>>>>>>>>> processing for user:: id: #{user.id}, email: #{user.email}, subscription_plan_status: #{user.subscription_plan_status} >>>>>>>>>>>"
      puts ">>>>>>>>>>> processing for user:: id: #{user.id}, email: #{user.email}, subscription_plan_status: #{user.subscription_plan_status} >>>>>>>>>>>"

      if user.expired!
        user_logger.debug ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
        puts ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"

        @count += 1
      else
        user_logger.debug ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
        puts ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
      end

      user_logger.debug ">>>>>>>>>>> process end for user:: id: #{user.id}, email: #{user.email}, subscription_plan_status: #{user.subscription_plan_status} >>>>>>>>>>>"
      puts ">>>>>>>>>>> process end for user:: id: #{user.id}, email: #{user.email}, subscription_plan_status: #{user.subscription_plan_status} >>>>>>>>>>>"

      user_logger.debug "==========================================================="
      puts "==========================================================="
    end

    user_logger.debug ">>>>>>>>>>> Total users affected:: #{@count} >>>>>"
    puts ">>>>>>>>>>> Total users affected:: #{@count} >>>>>"
  end

  def invalid_users_without_transactions
    invalid_users.select{|user| user.user_payment_methods.blank? && user.my_transactions.blank? }
  end

  def invalid_users
      active_users = User.where.not(role: 'Admin').where(is_free: false, subscription_plan_status: ['Activate', 'Trial'], registration_plan: ['Monthly', 'Annually', '', nil])

      invalid_web_android_users = active_users.where("sign_up_from IN (?)", ['web', 'android']).where(" customer_id IS NULL OR customer_id = ? AND subscription_id IS NULL OR subscription_id IN (?) ", '', '' )

      invalid_ios_users = active_users.iOS.where(" receipt_data IS NULL OR receipt_data = ?", '' )

      invalid_web_android_users + invalid_ios_users
  end

  def is_receipt_url?(user)
    if user.iOS?
      user.receipt_data.blank? ? 'No' : 'Yes'
    else
      user.receipt_data.blank? ? '-' : 'Yes'
    end
  end


  def is_payment_method?(user)
    if user.is_paid_user?
      user.user_payment_methods.blank? ? 'No' : 'Yes'
    else
      user.user_payment_methods.blank? ? '-' : 'Yes'
    end
  end

  def total_paid_amount(user)
    if user.check_user_free_or_not
      '-'
    else
      "$#{ActionController::Base.helpers.number_with_precision(user.total_amount_paid, precision: 3)}"
    end
  end

  def registration_date(user)
    user.created_at.to_s(:full_date_abbr_month_and_year_format)
  end

  def is_free?(user)
    user.is_free ? 'Yes' : 'No'
  end
end

# RAILS_ENV=production bundle exec rake analyse_users:generate_users_detailed_csv_file
# RAILS_ENV=production bundle exec rake analyse_users:generate_suspicious_users_detailed_csv_file
# RAILS_ENV=production bundle exec rake analyse_users:generate_filtered_suspicious_users_detailed_csv_file
# RAILS_ENV=production bundle exec rake analyse_users:set_subscription_plan_status_to_expired_for_invalid_users_without_transactions
