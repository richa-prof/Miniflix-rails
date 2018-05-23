module Api::Vm1::Concerns::UserCreate
  extend ActiveSupport::Concern

  def user_create_and_generate_response(user)
    user.build_logged_in_user(logged_in_params)
    user.save
    headers['authenticate'] = user.update_auth_token
    {code: "0", status: "Success", message: "Sign up successfully", user: user.create_hash, upgradable_user: user.valid_for_monthly_plan?, is_valid_payment: user.check_login}
  end

  def user_login_and_generate_response(user)
    is_login= user.check_login
    is_sign_up = user.registration_plan.blank?
    user.create_or_update_logged_in_user(logged_in_params)
    headers['authenticate'] = user.update_auth_token
    {code: "0", status: "Success", message: "Sign in successfully", user: user.create_hash ,is_sign_up: is_sign_up,is_valid_payment: is_login, upgradable_user: user.valid_for_monthly_plan?}
  end

  def update_ios_payment_and_generate_response(user)
    mode = logged_in_params[:notification_from]
    if IosPaymentUpdateService.new(user, mode).call();
      user.save!
      user.create_or_update_logged_in_user(params)
      { code: "0", status: "Success", message: "Payment successfully Updated", user: user.create_hash, is_valid_payment: user.check_login}
    else
      { code: "1", status: "Error", message: "Payment can not be updated"}
    end
  end
end