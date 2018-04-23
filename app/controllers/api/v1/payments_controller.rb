class Api::V1::PaymentsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def create
    if params[:payment_type] == "paypal"
      redirect_url = current_user.checkout_url
      render_json(redirect_url)
    else
      #code for stripe
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

  private
    def render_json(redirect_url)
      render json: {
        success: true,
        redirect_url: redirect_url
      }
    end

end
