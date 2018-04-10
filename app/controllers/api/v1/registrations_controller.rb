class Api::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  include Api::V1::Concerns::UserSerializeDataConcern

  def sign_up_params
    params.permit([:email, :password, :password_confirmation, :registration_plan, :name, :sign_up_from, :payment_type])
  end

  def render_create_success
    if @resource.Monthly? || @resource.Annually?
      if @resource.payment_type == "paypal"
        redirect_url = @resource.checkout_url
        render json: {
          success: true,
          redirect_url: redirect_url
        } and return if redirect_url.present?
      else
        #code for stripe card payment
      end
    end
    render json: {
      success: true,
      user:   serialize_user
    }
  end

  def render_create_error
    render json: {
      success: false,
      user:   serialize_user,
      errors: resource_errors
    }, status: 422
  end

  def render_create_error_email_already_exists
    response = {
      success: false,
      user:   serialize_user
    }
    message = I18n.t('devise_token_auth.registrations.email_already_exists', email: @resource.email)
    render_error(422, message, response)
  end

  def render_update_success
      render json: {
        status: 'success',
        user:   serialize_user
      }
  end
end
