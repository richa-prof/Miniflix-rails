class Stripe::UpdateCard

  def initialize(user, stripe_token)
    @user = user
    @stripe_token = stripe_token
  end

  def call
    update_card_detail_on_stripe(@user, @stripe_token)
  end

  private

  def update_card_detail_on_stripe(user, stripe_token)
    Stripe::Customer.update(user.customer_id, {
      source: stripe_token,
    })
    { success: true, message: I18n.t('flash.payment.card.successfully_updated') }
  rescue Stripe::InvalidRequestError => e
    {success: false, message: (I18n.t "payment.card.fail", error: stripe_error(e))}
  rescue Stripe::CardError => e
    {success: false, message: (I18n.t "payment.card.fail", error: stripe_error(e))}
  end

  def stripe_error(exception)
    exception.json_body[:error][:message]
  end

end
