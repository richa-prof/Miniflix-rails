class Api::V1::StripePaymentsController < ApplicationController
  before_action :set_user

  def hook
    event_type = params[:type]
    if event_type == "invoice.payment_succeeded"
      response = Stripe::TransactionSave.new(@user, params[:stripe_payment]).call
    elsif event_type == 'invoice.payment_failed' && !@user.expired?
      # Set user's `subscription_plan_status` to `Expired`.
      response = if @user.expired!
                   { sucess: true, message: 'successfully detail save' }
                 else
                   { sucess: false, message: @user.errors.full_messages }
                 end
    end

    render json: response
  end

  private
  def set_user
    @user = User.find_by_customer_id_and_subscription_id(customer_id, subscription_id)
    puts "user not present with customer_id: #{customer_id} and subscription_id: #{subscription_id}" unless @user
    render json: { message: "user not found" } and return unless @user
  end

  def payment_data_object
    params[:stripe_payment][:data][:object]
  end

  def customer_id
    payment_data_object[:customer]
  end

  def subscription_id
    payment_data_object[:subscription]
  end
end
