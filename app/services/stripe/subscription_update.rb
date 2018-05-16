class Stripe::SubscriptionUpdate < Stripe::SubscriptionCreate
  #this subscriptinon going to create new payment method for those user whose previous plan was paypal and now want to switch to paypal so this is actually new plan but it going to start after completing current plan expire date.

  private

  #override method-------------start

  def save_user_payment_detail(user, stripe_customer)
    assign_customer_id_and_subscription_id(user, stripe_customer)
    user.build_user_payment_method(UserPaymentMethod.payment_types["card"])
    user.valid_for_thankyou_page = true
    user.save

    { success: true,
      message: I18n.t('flash.payment_method.successfully_updated') }
  end

  def stripe_plan_attribute(user, stripe_token)
    {
      source: stripe_token,
      plan:  fetch_stripe_plan_id(user),
      email: user.email,
      trial_end: current_plan_expire_time(user)
    }
  end

  def update_subscription_plan_status(user)
    #no need to change subscription status for update plan it will be same as previous plan
  end

 #----end


  def current_plan_expire_time(user)
    calculate_day_in_current_subscription(user).to_i
  end

  def updated_plan_start_date(user)
    plan_expire_last_date(user) || payment_method_created_date_after_30day(user)
  end

  def plan_expire_last_date(user)
    latest_transaction  = user.my_transactions.last
    latest_transaction.try(:payment_expire_date)
  end

  def payment_method_created_date_after_30day(user)
    user.latest_payment_method.created_at
  end

  def calculate_day_in_current_subscription(user)
    plan_expire_date = updated_plan_start_date(user)
    if plan_expire_date > Time.now
      day_count = TimeDifference.between(Time.now, plan_expire_date).in_days
      return (Time.now + day_count.day)
    end
    Time.now
  end

end
