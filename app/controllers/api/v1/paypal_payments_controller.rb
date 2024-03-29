class Api::V1::PaypalPaymentsController < Api::V1::ApplicationController
  include EventTrackConcern
  skip_before_action :verify_authenticity_token, only: [:hook]
  before_action :set_user, except: [:hook]
  before_action :set_user_and_check_condition_for_hook, only: [:hook]

  def complete
    #"payment_success & make_payment" is name of component at frontend side
    if @user.confirm_payment(params[:token], params[:PayerID])
      facebook_pixel_event_track('paypal payment success', user_trackable_detail)

      redirect_to paypal_payment_url(t 'payment.paypal.thank_you')
    else
      facebook_pixel_event_track('paypal payment fail', user_trackable_detail) if @user

      @user.incomplete!

      target_url = if @user.registration_plan.blank?
                     paypal_payment_url(t 'payment.paypal.choose_plan')
                   else
                     paypal_payment_url(t 'payment.paypal.make_payment')
                   end

      redirect_to target_url
    end
  end

  def cancel
    facebook_pixel_event_track('Cancel paypal confirmation', user_trackable_detail) if @user

    target_url = if @user.registration_plan.blank?
                   paypal_payment_url(t 'payment.paypal.choose_plan')
                 else
                   paypal_payment_url(t 'payment.paypal.make_payment')
                 end

    redirect_to target_url
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
    if is_recurring_payment_failed
      @user.expired! unless @user.expired?
    else
      PaypalTransactionService.new(@user, params).call
    end

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

      Rails.logger.debug "<<<<< set_user_and_check_condition_for_hook::user : #{@user.try(:inspect)} << #{params['recurring_payment_id']} <<<<<"

      render json: {success: false} and return unless check_condition_for_hook
    end

    def check_condition_for_hook
      Rails.logger.debug "<<<<< check_condition_for_hook::user : #{@user.try(:inspect)} << #{params[:payment_status]} <<<<<"

      ( @user && (is_recurring_payment_profile_created || is_recurring_payment_deducted || is_recurring_payment_failed) )
    end

    def is_recurring_payment_profile_created
      (params['txn_type'] == 'recurring_payment_profile_created')
    end

    def is_recurring_payment_deducted
      (params['txn_type'] == 'recurring_payment') && (params[:payment_status].try(:downcase) == 'completed')
    end

    def is_recurring_payment_failed
      result = false
      if @user && (params['txn_type'] == 'recurring_payment')
        payment_status = params[:payment_status].try(:downcase)

        if ['expired', 'failed'].include?(payment_status)
          result = true
        end
      elsif @user && is_recurring_payment_outstanding_payment_failed
        result = true
      end

      result
    end

    def is_recurring_payment_outstanding_payment_failed
      (params['txn_type'] == 'recurring_payment_outstanding_payment_failed')
    end

    def paypal_payment_url(action_name)
      auth_token = @user.create_new_auth_token
      "#{ENV['Host']}/#{action_name}?client_id=#{auth_token['client']}&token=#{auth_token['access-token']}&uid=#{auth_token['uid']}&expiry=#{auth_token['expiry']}"
    end
end
