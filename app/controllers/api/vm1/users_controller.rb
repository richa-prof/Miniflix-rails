class Api::UsersController < ApplicationController
  include Api::Concerns::UserCreate
  before_action :authenticate_api, only: [:payment_history, :email_and_notification, :update_profile, :get_user_by_id]
  before_action :authenticate_user_and_temp_user, only: [:update_registration_plan]

  def contact_us
    begin
      @contact_us = ContactUs.new(contact_us_params)
      if @contact_us.save
        @response = { code: "0",status: "Success",message: "Successfully contact created",contact_us: @contact_us}
      else
        @response = { code: "1",status: "Error",message: @contact_us.errors}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  def payment_history
    begin
      user_payment_transactions = UserPaymentTransaction.joins(:user_payment_method => :user).where('user_payment_methods.user_id = ?', api_user.id).order(created_at:'desc').offset(params[:offset]).limit(params[:limit])
      if user_payment_transactions.present?
        response = { code: "0",status: "Success",message: "Successfully get user payment detail",user_payment: user_payment_transactions.as_json(methods: :payment_type)}
      else
        response = { code: "1",status: "Error",message: "No payment history found"}
      end
    rescue Exception => e
      response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: response
  end

  def email_and_notification
    email_and_notification = api_user.user_email_notification
    api_response = begin
      if email_and_notification.present?
        email_and_notification.update!(email_notification_params)
      else
        email_and_notification = api_user.user_email_notification.create!(email_notification_params)
      end
      { code: "0", status: "Success", message: "Email and notification settings are successfully saved", email_and_notification:  email_and_notification.as_json(except: [:created_at, :updated_at])}
    rescue Exception => e
      { code: "-1", status: "Error", message: e.message}
    end
    render json: api_response
  end

  def update_profile
    api_response = begin
      if api_user.authenticate(params[:user][:password])
        api_user.update_attributes!(update_user_params)
        {code: "0", status: "Success", message: "User updated successfully.", user: api_user.create_hash}
      else
        {code: "1", status: "Error", message: "Authentication Fail invalid password"}
      end
    rescue Exception => e
      {code: "-1", status:  "Error", message: e.message}
    end
    render json: api_response
  end

  def get_user_by_id
    render json: {code: "0", status: "Success", message: "User Found", user: api_user.create_hash, upgradable_user: api_user.valid_for_monthly_plan?,  is_valid_payment: api_user.check_login}
  end


  def update_registration_plan
    if params[:registration_plan] == "Educational" &&  FreeMember.find_by_email(@object.email).blank?
        api_response = {code: "1", status: "Error", message: "Email not added as free by admin"}
    else
      api_response = if @object.class.name == "User"
        update_registration_plan_for_old_user
      else
        initialize_user_and_update_plan
      end
    end
    render :json => api_response
  end

  def destroy
    if Rails.env.staging?
      begin
        user = User.find params[:id]
        user.destroy
        response = {code: "0", status: "Success", message: "user delete successfully"}
      rescue Exception => e
        response = {code: "-1", status: "Error", message: user.errors}
      end
    else
      response = {code: "1", status: "Error", message: "you can not delete user for #{Rails.env} environment"}
    end
    render json: response
  end

  private

    def contact_us_params
      params.require(:contact_us).permit(:name, :email, :school, :occupation)
    end

    def update_user_params
      params.require(:user).permit(:name,:email)
    end

    def email_notification_params
      params.require(:email_and_notification).permit(:product_updates, :films_added, :special_offers_and_promotions, :better_product, :do_not_send)
    end

    def user_params
      @object.registration_plan = params[:registration_plan]
      @object.as_json(except: [:created_at, :updated_at, :id])
    end

    def authenticate_user_and_temp_user
      @object = eval("#{params[:UserType]}.find_by_id_and_auth_token(params[:user_id], request.headers['authentication'])") if params[:user_id] && request.headers['authentication'] && params[:registration_plan]
      render json: {code: '-1', status: 'unauthorize request'} and return if @object.nil?
    end


    def update_registration_plan_for_old_user
      if @object.update_attributes(registration_plan: params[:registration_plan])
        {code: "0", status: "Success", message: "Registration plan updated Successfully"}
      else
        {code: "1", status: "Error", message: @object.errors}
      end
    end

    def initialize_user_and_update_plan
      user = User.new(user_params)
      if user.valid?
        generate_response_for_paid_user_and_freemium_user(user)
      else
        {code: "1", status: "Error", message: user.errors}
      end
    end

    def generate_response_for_paid_user_and_freemium_user(user)
      if user.Freemium? || user.Educational?
        user_create_and_generate_response(user)
      else
        @object.update_attribute('registration_plan', params[:registration_plan])
        {code: "0", status: "Success", message: "Registration plan updated Successfully"}
      end
    end

    def logged_in_params
      params.require(:user).permit(:device_type,:device_token,:notification_from) if params[:user]
    end
end
