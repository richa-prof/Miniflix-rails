class Api::V1::PaypalPaymentsController < Api::V1::ApplicationController
  before_action :set_user, except: [:hook]
  before_action :set_user_and_check_condition_for_hook, only: [:hook]

  def complete
    #"payment_success & make_payment" is name of component at frontend side
    if @user.confirm_payment(params[:token], params[:PayerID])
      redirect_to paypal_payment_url(t 'payment.paypal.thank_you')
    else
      @user.incomplete!
      redirect_to paypal_payment_url(t 'payment.paypal.make_payment')
    end
  end

  def cancel
    @user.incomplete!
    redirect_to paypal_payment_url(t 'payment.paypal.make_payment')
  end

  def update_payment
    if @user.confirm_for_update_payment(params[:token], params[:PayerID])
      redirect_to paypal_payment_url(t 'payment.paypal.my_account')
    else
      redirect_to paypal_payment_url(t 'payment.paypal.update_payment')
    end
  end

  def cancel_update
    redirect_to paypal_payment_url(t 'payment.paypal.update_payment')
  end

  def upgrade_payment
    if @user.confirm_for_upgrade_payment(params[:token], params[:PayerID])
      redirect_to paypal_payment_url(t 'payment.paypal.my_account')
    else
      redirect_to paypal_payment_url(t 'payment.paypal.upgrade_payment')
    end
  end

  def cancel_upgrade
    redirect_to paypal_payment_url(t 'payment.paypal.upgrade_payment')
  end

  # called on payment_confimration from payPal.
  # For more info Refer IPN(instant payment notification)
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

    def paypal_payment_url(action_name)
      auth_token = @user.create_new_auth_token
      "#{ENV['Host']}/#{action_name}?client_id=#{auth_token['client']}&token=#{auth_token['access-token']}&uid=#{auth_token['uid']}&expiry=#{auth_token['expiry']}"
    end
end
