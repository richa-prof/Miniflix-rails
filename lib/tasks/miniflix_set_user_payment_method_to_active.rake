namespace :miniflix do
  desc "set last user payment method's to active which have nil status"
  task set_user_payment_method_to_active: :environment do
    User.find_each do |user|
      user_payment_methods = user.user_payment_methods


      unless user_payment_methods.blank?
        active_payment_methods = user_payment_methods.active

        last_payment_method = if active_payment_methods.blank?
          user.user_payment_methods.last
        else
          active_payment_methods.last
        end

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

# RAILS_ENV=production bundle exec rake miniflix:set_user_payment_method_to_active
