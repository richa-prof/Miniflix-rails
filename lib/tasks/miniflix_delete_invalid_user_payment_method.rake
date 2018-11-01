namespace :miniflix do
  desc "delete the user payment method's whose user is not present in database."
  task delete_invalid_user_payment_method: :environment do
    UserPaymentMethod.find_each do |payment_method|
      if (!payment_method.valid? && payment_method.user.blank?)
        unless payment_method.destroy
          error_messages = payment_method.errors.full_messages
          Rails.logger.debug "<<<<<<<<< Successfully deleted user_payment_method due to errors:: #{error_messages} <<<<<<<<<"
          puts "<<<<<<<<< Successfully deleted user_payment_method due to errors:: #{error_messages} <<<<<<<<<"
        end
      end
    end
  end
end

# RAILS_ENV=production bundle exec rake miniflix:delete_invalid_user_payment_method
