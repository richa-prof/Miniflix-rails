namespace :update_user_payment_method do
  desc "delete the user payment method's whose user is not present in database."
  task delete_user_payment_method_dependent_to_users: :environment do
    UserPaymentMethod.find_each do |payment_method|
      if (!payment_method.valid? && payment_method.user.blank?)
        if payment_method.destroy
          error_messages = payment_method.errors.full_messages
          Rails.logger.debug "<<<<<<<<< Successfully deleted user_payment_method due to errors:: #{error_messages} <<<<<<<<<"
          puts "<<<<<<<<< Successfully deleted user_payment_method due to errors:: #{error_messages} <<<<<<<<<"
        end
      end
    end
  end

  desc "set last user payment method's to active which have nil status"
  task set_last_user_payment_method_to_active: :environment do
    User.find_each do |user|
      if user.latest_payment_method.blank?
        if user.user_payment_methods.active.blank?
          last_payment_method = user.user_payment_methods.last
          if last_payment_method.present?
            if last_payment_method.billing_plan.blank?
              billing_plan = user.fetch_billing_plan
              last_payment_method.billing_plan = billing_plan
            end

            if last_payment_method.valid?
              if last_payment_method.active!
                Rails.logger.debug "<<<<<<<<< Successfully updated user_payment_method: #{last_payment_method.id} <<<<<<<<<"
                puts "<<<<<<<<< Successfully updated user_payment_method: #{last_payment_method.id} <<<<<<<<<"
              end
            else
              error_messages = last_payment_method.errors.full_messages
              Rails.logger.debug "<<<<<<<<< #{last_payment_method.id} is still invalid. <<< errors:: #{error_messages} <<<<<<<<<"
              puts "<<<<<<<<< #{last_payment_method.id} is still invalid. <<< errors:: #{error_messages} <<<<<<<<<"
            end
          end
        end
      end
    end
  end

end

# RAILS_ENV=production bundle exec rake update_user_payment_method:delete_user_payment_method_dependent_to_users

# RAILS_ENV=production bundle exec rake update_user_payment_method:set_last_user_payment_method_to_active

# Note: To find invalid_user_payment_methods
# invalid_user_payment_methods = UserPaymentMethod.all.reject(&:valid?)
# invalid_user_payment_methods.count
# invalid_user_payment_methods.map{|u| u.errors.full_messages}
