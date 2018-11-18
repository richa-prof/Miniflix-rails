namespace :read_user_subscription_plan_status do
  desc "sync user_subscription_plan_status_with our payment gateway's(Paypal and Stripe)"
  task sync_user_subscription_plan_status_with_payment_gateway: :environment do
    user_logger = Logger.new("#{Rails.root}/log/read_sync_user_subscription_plan_status.log")
    @result = []
    payment_methods = UserPaymentMethod.active.paypal
    subscription_ids = payment_methods.map { |pm| pm.user.subscription_id }.reject(&:empty?).uniq
    subscription_ids.each do |id|
      user = User.find_by_subscription_id(id)
      ppr = PayPal::Recurring.new(profile_id: id)
      unless ppr.profile.active?
        user_logger.debug ">>>>>>>>>>> PayPal not inactive user:: id: #{user.id}, email: #{user.email} status: #{ppr.profile.try(:status)} >>>>>>>>>>>"
        user_logger.debug ">>>>>>>>>>> not inactive user:: id: #{user.id}, email: #{user.email}  >>>>>>>>>>>"
        puts ">>>>>>>>>>> not inactive user:: id: #{user.id}, email: #{user.email}  >>>>>>>>>>>"
      end
    end

    user_logger = Logger.new("#{Rails.root}/log/read_stripe_subscription_plan_status.log")
    payment_methods = UserPaymentMethod.active.card
    subscription_ids = payment_methods.map { |pm| pm.user.subscription_id }.reject(&:empty?).uniq

    subscription_ids.each do |subscription_id|
      user = User.find_by_subscription_id(subscription_id)
      begin
        subscription = Stripe::Subscription.retrieve(subscription_id)
        if subscription.status == 'unpaid' && !user.incomplete?
          user_logger.debug ">>>>>>>>>>> Stripe subscription user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          user_logger.debug ">>>>>>>>>>> not incomplete user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
          puts ">>>>>>>>>>> not incomplete user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
        elsif subscription.status == 'canceled' && !user.cancelled!
          user_logger.debug ">>>>>>>>>>> Stripe subscription user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          user_logger.debug ">>>>>>>>>>> not canceled user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
          puts ">>>>>>>>>>> not canceled user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
        elsif (user.cancelled? || user.incomplete?) && subscription.status == 'active'
          user_logger.debug ">>>>>>>>>>> Stripe subscription user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          user_logger.debug ">>>>>>>>>>> not active - cancelled or incomplete user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
          puts ">>>>>>>>>>> not active - cancelled or incomplete user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
        elsif (user.cancelled? || user.incomplete?) && subscription.status == 'trialing'
          user_logger.debug ">>>>>>>>>>> Stripe subscription user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          user_logger.debug ">>>>>>>>>>> not trialing - cancelled or incomplete user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
          puts ">>>>>>>>>>> not trialing - cancelled or incomplete user:: id: #{user.id}, email: #{user.email} status: #{subscription.status}  >>>>>>>>>>>"
        end
      rescue StandardError => e
        puts e.message
        user_logger.debug ">>>>>>>>>>> Stripe subscription user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
        user_logger.debug ">>>>>>>>>>> not have subscription for user:: id: #{user.id}, email: #{user.email} message: #{e.message} >>>>>>>>>>>"
      end
    end
    # subscription_ids.map do |i|
    #   begin
    #     subscription = Stripe::Subscription.retrieve(i)
    #   rescue StandardError => e
    #     e.message
    #   end
    # end
    user_logger.debug ">>>>>>>>>>> Total users:: #{@result.count} >>>>> #{@result}"
    puts ">>>>>>>>>>> Total users:: #{@result.count} >>>>> #{@result}"
  end

  desc "sync user_subscription_plan_status_with our payment gateway's(iOS)"
  task sync_ios_users_subscription_status: :environment do
    user_logger = Logger.new("#{Rails.root}/log/read_ios_users_subscription_status.log")
    @result = []
    @interrupted_users = []
    ios_secret = ENV['iOS_password']
    ios_users = User.iOS

    # next if (receipt_data.nil? || receipt_data.empty?)
    # user_logger.debug ">>>>>>>>>>> processing for user:: id: #{user.id}, email: #{user.email}, subscription_plan_status: #{user.subscription_plan_status} >>>>>>>>>>>"
    # puts ">>>>>>>>>>> processing for user:: id: #{user.id}, email: #{user.email}, subscription_plan_status: #{user.subscription_plan_status} >>>>>>>>>>>"
    ios_users.each do |user|
      receipt_data = user.receipt_data
      next if receipt_data.nil?
      next if receipt_data.empty?
      begin
        result = CANDY_CHECK_VERIFIER.verify_subscription(receipt_data, ios_secret)
        if result.expired? && !user.expired?
          user_logger.debug ">>>>>>>>>>> iOS subscription user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
          user_logger.debug ">>>>>>>>>>> not expired user:: id: #{user.id}, email: #{user.email} message: expired >>>>>>>>>>>"
          puts ">>>>>>>>>>> not expired user:: id: #{user.id}, email: #{user.email} message: expired >>>>>>>>>>>"
        end
      rescue StandardError => e
        use_message = result.try(:message)
        use_message = e.message unless use_message
        user_logger.debug ">>>>>>>>>>> Exception for user:: id: #{user.id}, email: #{user.email}, Exception: #{use_message} >>>>>>>>>>>"
        puts ">>>>>>>>>>> Exception for user:: id: #{user.id}, email: #{user.email}, Exception: #{use_message} >>>>>>>>>>>"
        @interrupted_users << { user_id: user.id, user_email: user.email, user_status: user.subscription_plan_status }
      end
    end

    user_logger.debug ">>>>>>>>>>> Total users affected:: #{@result.count} >>>>> #{@result}"
    puts ">>>>>>>>>>> Total users affected:: #{@result.count} >>>>> #{@result}"

    user_logger.debug ">>>>>>>>>>> Total interrupted_users:: #{@interrupted_users.count} >>>>> #{@interrupted_users}"
    puts ">>>>>>>>>>> Total interrupted_users:: #{@interrupted_users.count} >>>>> #{@interrupted_users}"
  end

  desc "sync user_subscription_plan_status_with outstanding_balance payment gateway's(Paypal)"
  task sync_user_subscription_plan_status_with_paypal_having_outstanding_balance: :environment do
    user_logger = Logger.new("#{Rails.root}/log/read_user_status_having_outstanding_bal.log")
    @result = []
    payment_methods = UserPaymentMethod.active.paypal
    subscription_ids = payment_methods.map { |pm| pm.user.subscription_id }.reject(&:empty?).uniq
    subscription_ids.each do |id|
      user = User.find_by_subscription_id(id)
      ppr = PayPal::Recurring.new(profile_id: id)
      profile = ppr.profile
      outstanding_bal = profile.outstanding_balance.to_i
      failed_count = profile.failed_count.to_i
      has_outstanding_bal = outstanding_bal.positive? # true
      failed = failed_count.positive? # true
      if failed || has_outstanding_bal
        user_logger.debug ">>>>>>>>>>> PayPal having_outstanding_balance  user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
        user_logger.debug ">>>>>>>>>>> not expired user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
        puts ">>>>>>>>>>> not expired user:: id: #{user.id}, email: #{user.email} >>>>>>>>>>>"
      end
    end
    user_logger.debug ">>>>>>>>>>> Total users affected:: #{@result.count} >>>>> #{@result}"
    puts ">>>>>>>>>>> Total users affected:: #{@result.count} >>>>> #{@result}"
  end
end

# Command to run the above task::

# 1. RAILS_ENV=production bundle exec rake read_user_subscription_plan_status:sync_user_subscription_plan_status_with_payment_gateway

# 2. RAILS_ENV=production bundle exec rake read_user_subscription_plan_status:sync_ios_users_subscription_status

# 3. RAILS_ENV=production bundle exec rake read_user_subscription_plan_status:sync_user_subscription_plan_status_with_paypal_having_outstanding_balance
