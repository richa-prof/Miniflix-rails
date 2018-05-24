class PaypalUpdateSubscription < PaypalSubscription

private
  def payment_options(action, billing_plan, user)
    options = {
      token: user.paypal_token,
      payer_id: user.customer_id,
      amount: billing_plan.amount,
      currency: billing_plan.currency,
      description: billing_plan.description,
      period: billing_plan.interval.capitalize,
      frequency: 1, #once in interval
      start_at: updated_plan_start_date(user)
    }
    options.merge!(extra_option(action, billing_plan, user)) if (action == :checkout)
    options
  end

  def extra_option(action, billing_plan, user)
    {
      return_url:  paypal_return_url_payment_success(user),
      cancel_url:  cancel_url_on_payment_cancel(user)
    }
  end

  def updated_plan_start_date(user)
    plan_expire_last_date(user) || payment_method_created_date_after_30day(user)
  end

  def plan_expire_last_date(user)
    latest_transaction  = user.my_transactions.last
    latest_transaction.try(:payment_expire_date)
  end

  def payment_method_created_date_after_30day(user)
    payment_method = user.user_payment_methods.active.last
    payment_method.created_at + 30.day
  end

  def paypal_return_url_payment_success(user)
    "#{ENV['RAILS_API_HOST']}/api/v1/paypal_payments/update_payment/#{user.id}"
  end

  def cancel_url_on_payment_cancel(user)
    "#{ENV['RAILS_API_HOST']}/api/v1/paypal_payments/cancel_update/#{user.id}"
  end

end
