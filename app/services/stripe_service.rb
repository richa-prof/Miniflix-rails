class StripeService

  def initialize(subscription_id)
    @subscription_id = subscription_id
  end

  def suspend_subscription
    suspend_opts = { at_period_end: true }
    cancel_stripe_subscription(suspend_opts)
  end

  def cancel_subscription
    cancel_stripe_subscription
  end

  private

  def cancel_stripe_subscription(period_end_opts=nil)
    begin
      subscription = Stripe::Subscription.retrieve(@subscription_id)

      if subscription.status == 'canceled'
        response = { success: false,
                     message: (I18n.t 'suspend_subscription.already_canceled') }
        puts 'Subscription already canceled.'
      else
        subscription.delete(period_end_opts)
        response = { success: true,
                     message: (I18n.t 'suspend_subscription.success') }
        puts 'subscription canceled!'
      end

    rescue Exception => e
      response = { success: false,
                   message: e.message }
      puts "====== response stripe error : #{e.message} ======"
    end

    response
  end
end