class Api::Vm1::PaymentsController < Api::Vm1::ApplicationController
  include Api::Vm1::Concerns::UserCreate
  before_action :authenticate_api, only: [:cancel_subscription, :reactive_cancelled_payment]
  before_action :authenticate_ios_user_api, only: [:update_receipt_data_of_user]

  def ios_webhook
    PAYMENT_LOGGER.debug "<<< Api::Vm1::PaymentsController::ios_webhook : parameters: #{params} <<<"

    response = ParseAppStoreHookService.new(params).call

    render json: response
  end

  def cancel_subscription
    user_payment_method = api_user.user_payment_methods.last
    begin
      if user_payment_method.card?
        subscription_cancel = api_user.stripe_subscription_cancel(at_period_end: true)
      elsif  user_payment_method.paypal?
        subscription_cancel = api_user.cancel_paypal_subscription
      end
      if subscription_cancel
        if api_user.cancelled!
          api_response = {code: "0", status: "Success", message: "Subscription has been cancelled successfully", user: api_user.create_hash}
        else
          api_response = {code: "1", status: "Error", message: api_user.errors}
        end
      else
        error_msg = api_user.errors || "Payment method not available"
        api_response = {code: "1", status: "Error", message: error_msg}
      end
    rescue Exception => e
      api_response = {code: "-1", status: "Error", message: e.message}
    end
    render json: api_response
  end

  def reactive_cancelled_payment
    user_payment_method = api_user.user_payment_methods.last
    begin
      if ((!api_user.iOS?) && user_payment_method.present?)
        is_payment_reactive = api_user.reactive_payment_subscription
        if is_payment_reactive
          api_user.activate!
          response = {code: "0", status: "Success", message: "Plan Successfully Reactivated", user: api_user.create_hash}
        else
          error_msg = api_user.errors || "subscription unable to active"
          response = {code: "1", status: "Error", message: error_msg}
        end
      else
        response = {code: "1", status: "Error", message: "Invalid user"}
      end
    rescue Exception => e
      response = {code: "-1", status: "Error", message: e.message}
    end
    render json: response
  end

  def update_receipt_data_of_user
    begin
      if @object.class.name == "TempUser"
        user = User.new(fetch_user_hash_from_temp_user)
        if user.valid?
          response = update_ios_payment_and_generate_response(user, params)
        else
          response = { code: "1",status: "Error",message: user.errors}
        end
      else
        @object.registration_plan = params[:registration_plan] if params[:registration_plan]
        @object.receipt_data = params[:receipt_data]
        response = update_ios_payment_and_generate_response(@object, params)
      end
    rescue Exception => e
      response = {code: "-1", status: "Error", message: e.message}
    end
    render :json => response
  end

  private

  def fetch_user_hash_from_temp_user
    @object.registration_plan = params[:registration_plan] if params[:registration_plan]
    @object.as_json(except: [:created_at, :updated_at, :id, :auth_token]).merge(temp_user_id: @object.id, receipt_data: params[:receipt_data])
  end

  def authenticate_ios_user_api
    @object = eval("#{params[:UserType]}.find_by_id_and_auth_token(params[:user_id], request.headers['authentication'])") if params[:user_id] && request.headers['authentication'] && params[:receipt_data]
    render json: {code: '-1', status: 'unauthorize request'} and return if @object.nil?
  end
end
