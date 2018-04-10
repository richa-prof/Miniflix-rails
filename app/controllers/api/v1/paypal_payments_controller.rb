class Api::V1::PaypalPaymentsController < ApplicationController
  before_action :set_user, except: [:hook]
  before_action :set_user_and_check_condition_for_hook, only: [:hook]

  def complete
    if @user.confirm_payment(params[:token], params[:PayerID])
      redirect_to paypal_payment_success_url
    else
      redirect_to paypal_payment_cancel_url
    end
  end

  def cancel
    redirect_to "#{ENV['Host']}/sign_up"
  end

  def hook
    PaypalTransactionService.new(@user, params).call
    render json: {success: true}
  end

  private
    def serialize_user
      ActiveModelSerializers::SerializableResource.new(@user,
      each_serializer: Api::V1::UserSerializer)
    end

    def set_user
      @user = User.find params[:user_id]
    end

    def set_user_and_check_condition_for_hook
      @user =  User.find_by_subscription_id (params["recurring_payment_id"])
      render json: {success: false} and return unless check_condition_for_hook
    end

    def check_condition_for_hook
      (@user && (params["txn_type"] == "recurring_payment") && (params[:payment_status].downcase == "completed"))
    end


    def paypal_payment_success_url
      auth_token = @user.create_new_auth_token
      "#{ENV['Host']}/payment_success?client_id=#{auth_token['client']}&token=#{auth_token['access-token']}&uid=#{auth_token['uid']}&expiry=#{auth_token['expiry']}"
    end

    def paypal_payment_cancel_url
      auth_token = @user.create_new_auth_token
      "#{ENV['Host']}/make_payment?client_id=#{auth_token['client']}&token=#{auth_token['access-token']}&uid=#{auth_token['uid']}&expiry=#{auth_token['expiry']}"
    end
end
