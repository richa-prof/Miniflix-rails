class Api::V1::PaymentsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def create
    if params[:payment_type] == "paypal"
      redirect_url = current_user.checkout_url
      render json: {
        success: true,
        redirect_url: redirect_url
      }
    else
      #code for stripe
    end
  end


end
