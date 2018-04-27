class Stripe::SubscriptionUpgrade

  def initialize(user)
    @user = user
  end

  def call
    upgrade_subscription(@user)
  end

  private

  def upgrade_subscription(user)
    stripe_retrive_subscription_and_upgrade(user)
    save_user_detail_for_annual_plan(user)
    {success: true, message: (I18n.t "payment_upgrade")}
  rescue Stripe::InvalidRequestError => e
    {success: false, message: (I18n.t "payment.card.fail", error: stripe_error(e))}
  rescue Stripe::CardError => e
    {success: false, message: (I18n.t "payment.card.fail", error: stripe_error(e))}
  end

  def stripe_retrive_subscription_and_upgrade(user)
    subscription = get_subscription(user)
    change_subscription_plan(subscription)
  end

  def get_subscription(user)
    customer = Stripe::Customer.retrieve(user.customer_id)
    customer.subscriptions.retrieve(user.subscription_id)
  end

  def change_subscription_plan(subscription)
    subscription.trial_end = "now"
    subscription.items = product_list_with_annual_plan(subscription)
    subscription.save
  end

  def product_list_with_annual_plan(subscription)
    [{
      id: fech_item_id(subscription),
      plan: annual_plan_id,
    }]
  end

  def fech_item_id(subscription)
    subscription.items.data[0].id
  end

  def annual_plan_id
    BillingPlan.year.last.stripe_plan_id
  end

  def save_user_detail_for_annual_plan(user)
    user.registration_plan = User.registration_plans['Annually']
    user.build_user_payment_method(UserPaymentMethod.payment_types['card'])
    user.save
  end

  def stripe_error(exception)
    exception.json_body[:error][:message]
  end
end
