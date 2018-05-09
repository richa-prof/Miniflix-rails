class Stripe::SubscriptionCreate

  def initialize(user, stripe_token)
    @user = user
    @stripe_token = stripe_token
  end

  def call
    subscribe_user_to_stripe(@user, @stripe_token)
  end

  private
  def subscribe_user_to_stripe(user, stripe_token)
    stripe_customer = Stripe::Customer.create(stripe_plan_attribute(user, stripe_token))
    save_user_payment_detail(user, stripe_customer)
  rescue Stripe::InvalidRequestError => e
    {success: false, message: (I18n.t "payment.card.fail", error: stripe_error(e))}
  rescue Stripe::CardError => e
    {success: false, message: (I18n.t "payment.card.fail", error: stripe_error(e))}
  end

  def fetch_stripe_plan_id(user)
    billing_plan = user.send(:fetch_billing_plan)
    billing_plan.stripe_plan_id
  end

  def save_user_payment_detail(user, stripe_customer)
    assign_customer_id_and_subscription_id(user, stripe_customer)
    user.build_user_payment_method(UserPaymentMethod.payment_types["card"])
    user.valid_for_thankyou_page = true
    user.save
    {success: true, message: (I18n.t "payment.card.success")}
  end

  def assign_customer_id_and_subscription_id(user, customer_object)
    user.customer_id = customer_object.id
    subscription_detail = customer_object[:subscriptions].data.first
    user.subscription_id = subscription_detail.id
    update_subscription_plan_status(subscription_detail)
  end

  def get_subscription_plan_status(subscription_detail)
    case subscription_detail.status
    when "active"
      User.subscription_plan_statuses['activate']
    when "trialing"
      User.subscription_plan_statuses['trial']
    else
      #past_due, unpaid
      User.subscription_plan_statuses['incomplete']
    end
  end

  def stripe_error(exception)
    exception.json_body[:error][:message]
  end

  protected

  def stripe_plan_attribute(user, stripe_token)
    {
      source: stripe_token,
      plan:  fetch_stripe_plan_id(user),
      email: user.email
    }
  end

  def update_subscription_plan_status(subscription_detail)
    @user.subscription_plan_status = get_subscription_plan_status(subscription_detail)
  end
end
