namespace :miniflix do
  desc 'Set user subscription plan'
  task set_user_subscription_plan_status: :environment do
    user_logger = Logger.new("#{Rails.root}/log/sync_user_subscription_plan_status.log")

    User.user.all.each do |user|
      if user.Educational? || user.Freemium?
        user_logger.debug ">>>>>>>>>>> this is a free user:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
        puts ">>>>>>>>>>> this is a free user:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
      else
        payment_methods = user.user_payment_methods
        if payment_methods.blank?
          message = case user.subscription_plan_status
          when 'incomplete' || 'Incomplete'
            ">>>>>>>>>>> this paid user is incomplete now:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
          when 'trial' || 'Trial'
            subscription_id = user.subscription_id
            receipt_data = user.receipt_data
            if subscription_id.blank? && receipt_data.blank?
              if user.incomplete!
                ">>>>>>>>>>> this paid user was in trial and now become incomplete now:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
              else
                ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
              end
            else
              profile_found = false
              if !subscription_id.blank?
                profile_found = check_on_paypal(user)
                profile_found = check_on_stripe(user) if !profile_found
              end

              if !receipt_data.blank? && !profile_found
                profile_found = check_on_ios(user)
              end
            end
          when 'activate' || 'Activate'
          when 'cancelled' || 'Cancelled'
          when 'expired' || 'Expired'

          end

          user_logger.debug message
          puts message
        else
          active_payment_method = payment_methods.active.last


        end
      end
    end
  end

  def check_on_paypal(user)
    ppr = PayPal::Recurring.new(profile_id: user.subscription_id)
    status = ppr.profile.status

    create_payment_method(user, !!status, 'Paypal', ppr) if status

    !!status
  end

  def check_on_stripe(user)
    status = false
    begin
      subscription = Stripe::Subscription.retrieve(user.subscription_id)
      status = true
      create_payment_method(user, status, 'Card', subscription)
    rescue Exception => e
      puts e.message
    end
    status
  end

  def check_on_ios(user)
    ios_secret = ENV['iOS_password']
    result = CANDY_CHECK_VERIFIER.verify_subscription(receipt_data, ios_secret)

  end

  def create_payment_method(user, profile_found, pay_via, pay_profile)
    if profile_found
      case pay_via
      when 'Paypal'
        if pay_profile.profile.try(:status) == :canceled || pay_profile.profile.outstanding_balance.to_i > 0 || pay_profile.profile.failed_count.to_i > 0

          if user.expired!
            ">>>>>>>>>>> this paid user was in Trial and now become Expired now:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
          else
            ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          end
        elsif pay_profile.profile.try(:status) == :active
          if user.activate!
            ">>>>>>>>>>> this paid user was in Trial and now become Active now:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
          else
            ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          end
        elsif pay_profile.profile.try(:status) == :suspended
          # Need to write case for this
        end
      when 'Card'

      when 'iOS'

      end
      payment_method = user.build_user_payment_methods(pay_via)
        # Need to create payment method
    else
      if user.incomplete!
        ">>>>>>>>>>> this paid user was in trial and now become incomplete now:: id: #{user.id}, email: #{user.email}, registration_plan: #{user.registration_plan} >>>>>>>>>>>"
      else
        ">>>>>>>>>>> updation failed for user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
      end
    end
  end
end
