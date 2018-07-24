class PaymentsController < ApplicationController
  include UserLoginConcern
  include EventTrackConcern
  layout :choose_layout

  before_action :set_user, only: [:paypal_success, :paypal_cancel]
  before_action :set_android_user_and_save_registration_detail, only: [:android_payment_process_for_old_user]


  def android_payment_old_user_view
    user = User.find_by_id params[:id]
    redirect_to 'miniflix://mob?is_payment_success=false&error_code=1&msg=User not found' and return if (user.nil? || params[:registration_plan].nil?)
    @user_payment_method = user.user_payment_methods.last
    @user_payment_method = user.user_payment_methods.build if @user_payment_method.nil?

    @user = user
    facebook_pixel_event_track('Android user go for Subscription', user_trackable_detail)

    session[:android_user] = user.id
  end


  def android_payment_process_for_old_user
    payment_type = user_payment_method_params[:payment_type].try(:downcase)
    if payment_type == User::PAYMENT_TYPE_PAYPAL
      set_registration_plan_for(@user)
      redirect_url = @user.checkout_url(User::PLATFORMS[:android])
      redirect_to redirect_url and return if redirect_url
      redirect_to 'miniflix://mob?is_payment_success=false&error_code=2&msg=Your paypal access token is invalid.'
    else
      set_registration_plan_for(@user)
      response = Stripe::SubscriptionCreate.new(@user, stripe_token).call if stripe_token
      unless (response && response[:success]) #subscription fail on stripe
        facebook_pixel_event_track("stripe payment fail", user_trackable_detail)

        redirect_to "miniflix://mob?is_payment_success=false&error_code=2&msg=#{@user.errors}"
      else
        facebook_pixel_event_track("stripe payment success", user_trackable_detail)

        redirect_to 'miniflix://mob?is_payment_success=true&error_code=0&msg=Stripe Payment successfully done.'
      end
    end
  end

  def paypal_cancel
    facebook_pixel_event_track('Android user cancel paypal confirmation', user_trackable_detail) if @user

    redirect_to 'miniflix://mob?is_payment_success=false&error_code=2&msg=Your payment token is invalid.'
  end

  def paypal_success
    if @user.confirm_payment(params[:token], params[:PayerID])
      facebook_pixel_event_track('Android user paypal payment success', user_trackable_detail)
      redirect_to 'miniflix://mob?is_payment_success=true&error_code=0&msg=Payment successfully done.'
    else
      facebook_pixel_event_track('Android user paypal payment fail', user_trackable_detail) if @user
      @user.incomplete!
      redirect_to 'miniflix://mob?is_payment_success=false&error_code=2&msg=Your payment token is invalid.'
    end
  end

  private

  def stripe_token
    params[:stripeToken]
  end

  def registration_plan
    params[:registration_plan]
  end

  def set_registration_plan_for(user)
    user.registration_plan = User.registration_plans[registration_plan] if registration_plan.present?
  end

  def payment_method_params
    {payment_type: params[:payment_type], first_name: params[:first_name], last_name: params[:last_name], card_number: params[:card_number], expiration_month: params[:expiration_month], expiration_year: params[:expiration_year], card_CVC: params[:card_CVC]}
  end

  def user_payment_method_params
    params[:user_payment_method].permit(:payment_type, :first_name, :last_name, :card_number, :expiration_month, :card_CVC, :expiration_year)
  end

  def choose_layout
    if [ 'android_payment_old_user_view', 'android_payment_process_for_old_user'].include?params[:action]
      "app_layout"
    else
      "application"
    end
  end

  def set_android_user_and_save_registration_detail
    begin
      @user = User.find params[:id] if session[:android_user] == params[:id].to_i
      @user.email = params[:new_email] if params[:new_email]
      @user.save!
    rescue ActiveRecord::RecordInvalid => invalid
      redirect_to "miniflix://mob?is_payment_success=false&error_code=1&msg=#{invalid.message}" and return
    rescue Exception => e
      redirect_to 'miniflix://mob?is_payment_success=false&error_code=1&msg=Invalid Request' and return
    end
  end

  def set_user
    @user = User.find params[:user_id]
  end
end
