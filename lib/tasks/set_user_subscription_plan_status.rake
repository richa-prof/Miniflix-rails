namespace :set_user_subscription_plan_status do
  desc "sync user_subscription_plan_status_with our payment gateway's(Paypal and Stripe)"
  task sync_user_subscription_plan_status_with_payment_gateway: :environment do
    user_logger = Logger.new("#{Rails.root}/log/sync_user_subscription_plan_status.log")
    @result = []
    payment_methods = UserPaymentMethod.active.paypal
    subscription_ids = payment_methods.map {|pm| pm.user.subscription_id}.uniq
    subscription_ids.each do |id|
      user = User.find_by_subscription_id(id)
      ppr = PayPal::Recurring.new(profile_id: id)

      if ppr.profile.try(:status) == 'canceled'.to_sym
        if user.expired!
          user_logger.debug ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          puts ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"

          @result << { user_id: user.id, user_email: user.email, user_status: user.subscription_plan_status, payment_gateway_status: ppr.profile.try(:status) }
        else
          user_logger.debug ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          puts ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
        end
      end

    end

    card_results = []
    payment_methods = UserPaymentMethod.active.card
    subscription_ids = payment_methods.map {|pm| pm.user.subscription_id}.uniq

    subscription_ids.each do |subscription_id|
      begin
        subscription = Stripe::Subscription.retrieve(subscription_id)
        user = User.find_by_subscription_id(subscription_id)

        if (subscription.status == 'unpaid')
          if user.incomplete!
            user_logger.debug ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"

            @result << { user_id: user.id, user_email: user.email, user_status: user.subscription_plan_status, payment_gateway_status: subscription.status }
          else
            user_logger.debug ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          end
        elsif subscription.status == 'canceled'
          if user.cancelled!
            user_logger.debug ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"

            @result << { user_id: user.id, user_email: user.email, user_status: user.subscription_plan_status, payment_gateway_status: subscription.status }
          else
            user_logger.debug ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          end
        elsif ((user.cancelled? || user.incomplete?) && subscription.status == 'active')
          if user.activate!
            user_logger.debug ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"

            @result << { user_id: user.id, user_email: user.email, user_status: user.subscription_plan_status, payment_gateway_status: subscription.status }
          else
            user_logger.debug ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          end
        elsif ((user.cancelled? || user.incomplete?) && subscription.status == 'trialing')
          if user.trial!
            user_logger.debug ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> successfully updated user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"

            @result << { user_id: user.id, user_email: user.email, user_status: user.subscription_plan_status, payment_gateway_status: subscription.status }
          else
            user_logger.debug ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
            puts ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          end
        end
      rescue Exception => e
        puts e.message
      end
    end

    user_logger.debug ">>>>>>>>>>> Total users affected:: #{@result.count} >>>>> #{@result}"
    puts ">>>>>>>>>>> Total users affected:: #{@result.count} >>>>> #{@result}"
  end

end

# Command to run the above task::
# RAILS_ENV=production bundle exec rake set_user_subscription_plan_status:sync_user_subscription_plan_status_with_payment_gateway
