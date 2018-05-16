class PaypalSubscription

  def initialize(action, user)
    @action = action
    @user = user
  end

  def call
    subscribe_user_to_paypal_recurring(@action, @user)
  end

  private

  def subscribe_user_to_paypal_recurring(action, user)
    billing_plan = fetch_billing_plan(user)
    paypal_process(action, billing_plan, user)
  end

  def paypal_process(action, billing_plan, user)
    paypal = PayPal::Recurring.new(payment_options(action, billing_plan, user))
    response = paypal.send(action)
    Rails.logger.debug "<<<<< paypal_process::response.errors : #{response.errors} <<<<<"

    return false if response.errors.present?
    response
  end

  protected

  def fetch_billing_plan(user)
    user.send(:fetch_billing_plan)
  end

  def payment_options(action, billing_plan, user)
    options = {
      token: user.paypal_token,
      payer_id: user.customer_id,
      amount: billing_plan.amount,
      currency: billing_plan.currency,
      description: billing_plan.description,
      period: billing_plan.interval.capitalize,
      frequency: 1, #once in interval
      start_at: Time.now
    }.merge(extra_option(action, billing_plan, user))

  end

  def extra_option(action, billing_plan, user)
    case action
    when :checkout
      {
        return_url:  paypal_return_url_payment_success(user),
        cancel_url:  cancel_url_on_payment_cancel(user)
      }
    when :create_recurring_profile
      if (billing_plan.trial_days.present? && billing_plan.trial_days != 0)
        {
          :trial_length    => 1,
          :trial_period    => billing_plan.interval.capitalize,
          :trial_frequency => 1,
          :outstanding => :next_billing
        }
      else
        {}
      end
    end
  end

  def paypal_return_url_payment_success(user)
    if user.Android?
      "#{ENV['RAILS_HOST']}/paypal_success/#{user.id}"
    else
      "#{ENV['RAILS_HOST']}/api/v1/paypal_payments/complete/#{user.id}"
    end
  end

  def cancel_url_on_payment_cancel(user)
    if user.Android?
      "#{ENV['RAILS_HOST']}/paypal_cancel/#{user.id}"
    else
      "#{ENV['RAILS_HOST']}/api/v1/paypal_payments/cancel/#{user.id}"
    end
  end

end
