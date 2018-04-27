class Api::V1::StripePaymentsController < ApplicationController
  before_action :set_user

  def hook
    if params[:type] == "invoice.payment_succeeded"
      response = Stripe::TransactionSave.new(@user, params[:stripe_payment]).call
    else
      #TODO: need to implement payment fail scenario need to expire user subscription status
    end
    render json: response
  end

  private
  def set_user
    @user = User.find_by_customer_id_and_subscription_id(customer_id, subscription_id)
    puts "user not present" unless @user
    render json: {message: "user not found"} and return unless @user
  end

  def customer_id
    params[:stripe_payment][:data][:object][:customer]
  end

  def subscription_id
    params[:stripe_payment][:data][:object][:subscription]
  end
end
