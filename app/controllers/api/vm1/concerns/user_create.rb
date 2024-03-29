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

  def update_ios_payment_and_generate_response(user, extra_params={})
    mode = params[:build_type] rescue nil

    unless mode
      mode = user.logged_in_user.try(:notification_from)
    end

    response = IosPaymentUpdateService.new(user, mode, extra_params).call();

    if response[:success]
      user.save!
      user.create_or_update_logged_in_user(params)
      user_detailed_hash = user.create_hash.merge(transaction_amount: response[:transaction].try(:amount))

      { code: "0",
        status: "Success",
        message: "Payment successfully Updated",
        user: user_detailed_hash,
        is_valid_payment: user.check_login }
    else
      PAYMENT_LOGGER.debug "<<< Api::Vm1::Concerns::UserCreate::update_ios_payment_and_generate_response : user_id: #{user.id}, error: #{response[:error]}, parameters: #{extra_params} <<<"

      { code: "1",
        status: "Error",
        message: response[:error] }
    end
  end
end