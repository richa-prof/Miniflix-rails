class Api::V1::PaymentsController < Api::V1::ApplicationController
  include Api::V1::Concerns::UserSerializeDataConcern
  before_action :authenticate_user!
  before_action :check_user_valid_for_upgrade_plan, only: [:upgrade]

  def create
    if params[:payment_type] == "paypal"
      redirect_url = current_user.checkout_url
      render_json(redirect_url)
    else
      subscription_done = Stripe::SubscriptionCreate.new(@resource, params["stripe_token"]).call if params["stripe_token"]
      if !(subscription_done && subscription_done[:success]) #subscription fail on stripe
        render_json_for_card_fail(subscription_done)
      else
        render_json_for_card_success(subscription_done)
      end
    end
  end

  def update
    if params[:payment_type] == "paypal"
      redirect_url = current_user.update_checkout_url
      render_json(redirect_url)
    else
       #code for stripe
    end
  end

  def upgrade
    if params[:payment_type] == "paypal"
      redirect_url = current_user.upgrade_checkout_url
      render_json(redirect_url)
    else
      #code for stripe
    end

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

    def render_json_for_card_fail(subscription)
      error_message = ((subscription && subscription[:message]) ?  subscription[:message] : (I18n.t "payment.card.fail", error: "invaild token,"))
      render json: {
        status: 'fail',
        user:   serialize_user,
        errors: error_message
      } and return
    end

    def render_json_for_card_success(subscription)
      render json: {
        status: 'success',
        user:   serialize_user,
        message: subscription[:message]
      } and return
    end
end
