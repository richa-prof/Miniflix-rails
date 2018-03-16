class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :authenticate_user!
  before_action :check_current_password, only: [:send_verification_code]
  before_action :check_verification_code, only: [:verify_verification_code]

  def send_verification_code
    if current_user.update_attributes(user_update_phone_params)
     response = {success: true, message: "Verification code is sent to your entered phone number, verify phone number for complete process."}
    else
      response = {success: false, message: current_user.errors}
    end
    render json: response
  end

  def verify_verification_code
    current_user.update_attribute('verification_code', nil)
    render json: {success: true, message: "Phone number successful updated"}
  end


  private

  def check_current_password
     render json: {success: false, message: "invalid current password" } if !authenticate_password
  end

  def authenticate_password
    current_user.valid_password?(params[:user][:current_password])
  end

  def user_update_phone_params
    params.require(:user).permit(:unconfirmed_phone_number)
  end

  def check_verification_code
     render json: {success: false, message: "invalid code" } unless current_user.valid_verification_code?(params[:verification_code])
  end
end
