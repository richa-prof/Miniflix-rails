class Api::Vm1::SessionsController < Api::Vm1::ApplicationController
  include Api::Vm1::Concerns::UserCreate
  before_action :authenticate_api, only: [:change_password, :edit_phone_number, :sign_out]

  def sign_in
    if params[:user][:email].present? && params[:user][:password].present?
      user = User.find_by_email(params[:user][:email])
      if user && user.valid_password?(params[:user][:password])
        begin
          response = user_login_and_generate_response(user)
        rescue Exception => e
          response = {:code => "-1",:status => "Error",:message => e.message}
        end
      else
        response = {:code => "1",:status => "Error",:message => "Invalid Email/Password"}
      end
    else
      response = {:code => "1",:status => "Error",:message => "Please pass email/password"}
    end
    render :json => response
  end

  def sign_out
    begin
      api_user.logged_in_user.update(device_type: "",device_token:"",notification_from: "") if api_user.logged_in_user.present?
      api_user.destroy_auth_token
      api_response = {code: "0", status: "Success", message: "Sign out successfully"}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
      render json: api_response
  end

  def sign_up
    begin
      user = User.find_by(email: params[:user][:email])

      if user.present?
        api_response = {code: "1", status: "Error", message: "Email already exist"}
      else
        user = User.new(user_params)
        if user.valid?
          if user.Educational? || user.Freemium?
            api_response = check_for_education_and_freemium_plan(user)
          else
            api_response = generate_response_for_paid_user(user)
          end
        else
          api_response = {code: "-1", status: "Error", message: user.errors.full_messages[0]}
        end
      end
    rescue Exception => e
      api_response = {code: "-1", status: "Error", message: e.message}
    end
    render json: api_response
  end

  def social_sign_in
    begin
      if params[:user][:uid].present? && params[:user][:provider].present?
        user = User.check_user_already_present_or_not(params[:user][:provider], params[:user][:uid])
        if user.present?
          response = user_login_and_generate_response(user)
        else
          user = User.new(social_user_params)
          user.registration_plan = "Freemium" if user.Android?

          if user.valid? || user.invalid_only?('registration_plan')
            if user.iOS?
              temp_user_id = TempUser.save_user_detail_into_temp_user(user, "social_authenticate")
              temp_user = TempUser.find (temp_user_id)
              headers['authenticate'] = temp_user.update_auth_token
              response = {code: "0", status: "Success", message: "Select plan for further process", temp_user: TempUser.json_content(temp_user_id), is_sign_up: true,is_valid_payment: false }
            else
              response = user_create_and_generate_response(user)
            end
          else
            response = {code: "-1", status: "Error", message: user.errors}
          end
        end
      else
        response = {code: "1", status: "Error", message: "Please pass uid/provider"}
      end
    rescue Exception => e
      response = {code: "-1", status: "Error", message: e.message}
    end
    render json: response
  end

  def change_password
    if params[:user][:current_password] && params[:user][:new_password]
      begin
        password_update = api_user.update_attribute('password', params[:user][:new_password]) if api_user.valid_password?(params[:user][:current_password])
        if password_update
          response = {code: "0", status: "Success", message: "Password updated successfully", user: api_user.create_hash}
        else
          response = { code: "1", status: "Error", message: "Invalid Current Password"}
        end
      rescue Exception => e
        response = { code: "-1", status: "Error", message: e.message}
      end
    else
      response = { code: "1", status: "Error", message: "Incomplete information"}
    end
    render json: response
  end

  #allows to edit phone number
  def edit_phone_number
    begin
      if params[:user][:phone_number].present?
        @user = api_user
        if @user && params[:user][:password].present?
          authorized_user = @user.valid_password?(params[:user][:password])
        elsif @user && params[:user][:email].present?
          authorized_user = @user.email == params[:user][:email] ? @user : nil
        else
          authorized_user=@user
        end
        if authorized_user
          if params[:user][:verification_code].present?
            if @user.verification_code == params[:user][:verification_code]
              if @user.update(phone_number: params[:user][:phone_number],verification_code: nil)
              @response = {:code => "0",:status => "Success",:message => "Phone number updated successfully",:user => @user.create_hash}
              else
              @response = {:code => "1",:status => "Error",:message => "Error while updating phone number",:user => @user.errors}
              end
            else
              @response = {:code => "2",:status => "Error",:message => "Wrong verification code"}
            end
          else
            verification_code = rand(1000...9999)
            to_number = "#{params[:countries]}#{params[:user][:phone_number]}"
            body = "Your phone number successfully updated on miniflix and your verification code is #{verification_code}"

            twillo_response = TwilioService.new(to_number, body).call()

            if twillo_response[:success]
              @response = {:code => "0",:status => "Success",:message => "Successfully sent verification code on your phone number."}
              @user.update_attributes(:verification_code => verification_code)
            else
              @response = {:code => "-1",:status => "Error",:message => twillo_response[:message]}
            end
          end
        else
        @msg = params[:user][:email].present? ? "Invalid email" : "Invalid Current Password"
        @response = {:code => "3",:status => "Error",:message => @msg}
        end
      else
        @response = {:code => "4",:status => "Error",:message => "Please pass user_id/phone_number/password/email"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render :json => @response
  end

  #sends reset password instructions
  def forgot_password
    begin
      if params[:email].present?
        user = User.find_by_email(params[:email])
        if user
          user.send_reset_password_instructions({
            redirect_url: forgot_password_redirect_url
          })

          response = {:code => "0",:status => "Success",:message => "Reset password instruction details has been sent to your email"}
        else
          response = {:code => "1",:status => "Error",:message => "User not exist"}
        end
      else
        response = {:code => "1",:status => "Error",:message => "Please pass an email"}
      end
    rescue Exception => e
      response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render :json => response
  end

  private
    # Whitelist all user params
    def user_params
      use_params = params.require(:user).permit(:name, :email, :password, :subscription_id, :customer_id, :image, :provider, :uid, :registration_plan, :sign_up_from, :receipt_data)
      sign_up_from_param = use_params[:sign_up_from].try(:downcase)
      use_params[:sign_up_from] = sign_up_from_param

      use_params
    end

    def social_user_params
      use_params = params.require(:user).permit(:name,:email,:password,:subscription_id,:customer_id,:image,:provider,:uid,:sign_up_from,:receipt_data).merge(password: "12345678")

      sign_up_from_param = use_params[:sign_up_from].try(:downcase)
      use_params[:sign_up_from] = sign_up_from_param

      use_params
    end

    def logged_in_params
      params.require(:user).permit(:device_type,:device_token,:notification_from)
    end

    def check_for_education_and_freemium_plan(user)
      if user.Freemium? || (FreeMember.find_by_email(user.email).present?)
        user_create_and_generate_response(user)
      else
        {:code => "1",:status => "Error",:message => "Email not added as free by admin"}
      end
    end

    def generate_response_for_paid_user(user)
      if user.iOS?
        ios_user_sign_up(user)
      else
        android_paid_user(user)
      end
    end

    def ios_user_sign_up(user)
      if IosPaymentUpdateService.new(user).call();
        user_create_and_generate_response(user)
      else
        {code: "-1", status: "Error", message: "user can't create, something wrong with ios receipt"}
      end
    end

    def android_paid_user(user)
      temp_user_id = TempUser.save_user_detail_into_temp_user(user)
      temp_user = TempUser.find (temp_user_id)
      headers['authenticate'] = temp_user.update_auth_token
      {code: "0", status: "Success", message: "Choose payment type for further process", temp_user: TempUser.json_content(temp_user_id)}
    end

    def forgot_password_redirect_url
      "#{ENV['Host']}/update_password"
    end
end