class Api::V1::PaymentsController < Api::V1::ApplicationController
  include Api::V1::Concerns::UserSerializeDataConcern
  before_action :authenticate_user!
  before_action :check_user_valid_for_upgrade_plan, only: [:upgrade]

  def create
    if payment_type == User::PAYMENT_TYPE_PAYPAL
      set_registration_plan_for(current_user)
      redirect_url = current_user.checkout_url
      render_json(redirect_url)
    else
      set_registration_plan_for(@resource)
      response = Stripe::SubscriptionCreate.new(@resource, stripe_token).call if stripe_token
      unless (response && response[:success]) #subscription fail on stripe
        render_json_for_card_fail(response)
      else
        render_json_for_card_success(response)
      end
    end
  end

  def update
    if payment_type == User::PAYMENT_TYPE_PAYPAL
      redirect_url = current_user.update_checkout_url
      render_json(redirect_url)
    else
      response = current_user.update_card_payment(stripe_token) if stripe_token
      unless (response && response[:success]) #subscription fail on stripe
        render_json_for_card_fail(response)
      else
        render_json_for_card_success(response)
      end
    end
  end

  # we are supposing user try to upgrade payment with his default payment method.
  def upgrade
    if current_user.latest_payment_method.paypal?
      redirect_url = current_user.upgrade_checkout_url
      render_json(redirect_url)
    else
      response = current_user.upgrade_payment_through_card
      if  response[:success]
        render_json_for_card_success(response)
      else
        render_json_for_card_fail(response)
      end
    end
  end

  def suspend
    response = current_user.suspend_subscription

    render json: response.merge(user: serialize_user)
  end

  def reactivate
    response = current_user.reactivate_subscription

    render json: response.merge(user: serialize_user)
  end

  private

  def render_json(redirect_url)
    render json: {
      success: true,
      redirect_url: redirect_url
    }
  end

  def check_user_valid_for_upgrade_plan
    render json: {success: false, message: "you are not authorize to upgrade payment"}  unless (current_user.Monthly? && current_user.trial?)
  end

  def render_json_for_card_fail(response)
    error_message = ((response && response[:message]) ?  response[:message] : (I18n.t "payment.card.fail", error: "invaild token,"))

    render json: {
      status: 'fail',
      user:   serialize_user,
      errors: error_message
    } and return
  end

  def render_json_for_card_success(response)
    render json: {
      status: 'success',
      user:   serialize_user,
      message: response[:message]
    } and return
  end

  def stripe_token
    params['stripe_token']
  end

  def payment_type
    params[:payment_type]
  end

  def set_registration_plan_for(user)
    user.registration_plan = User.registration_plans[payment_type] if payment_type.present?
  end
end
