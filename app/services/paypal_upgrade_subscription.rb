class PaypalUpgradeSubscription < PaypalSubscription

private

  def fetch_billing_plan(user)
    BillingPlan.Year.last
  end

  def payment_options(action, billing_plan, user)
    options = {
      token: user.paypal_token,
      payer_id: user.customer_id,
      amount: billing_plan.amount,
      currency: billing_plan.currency,
      description: billing_plan.description,
      period: billing_plan.interval,
      frequency: 1, #once in interval
      start_at: Time.now
    }
    options.merge!(extra_option(user)) if (action == :checkout)
    options
  end

  def extra_option(user)
    {
      return_url:  paypal_return_url_payment_success(user),
      cancel_url:  cancel_url_on_payment_cancel(user)
    }
  end

  def paypal_return_url_payment_success(user)
    "#{ENV['RAILS_HOST']}/api/v1/paypal_payments/upgrade_payment/#{user.id}"
  end

  def cancel_url_on_payment_cancel(user)
    "#{ENV['RAILS_HOST']}/api/v1/paypal_payments/cancel_upgrade/#{user.id}"
  end

end
1
