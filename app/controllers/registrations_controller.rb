class RegistrationsController < DeviseTokenAuth::RegistrationsController

  def sign_up_params
    params.permit([:email, :password, :password_confirmation, :registration_plan, :name, :sign_up_from])
  end

  def render_create_success
    render json: {
      status: 'success',
      user:   serialize_user
    }
  end

  def render_create_error
    render json: {
      status: 'error',
      user:   serialize_user,
      errors: resource_errors
    }, status: 422
  end

  def render_create_error_email_already_exists
    response = {
      status: 'error',
      user:   serialize_user
    }
    message = I18n.t('devise_token_auth.registrations.email_already_exists', email: @resource.email)
    render_error(422, message, response)
  end

  private
    def serialize_user
      ActiveModelSerializers::SerializableResource.new(@resource,
      each_serializer: Api::V1::UserSerializer)
    end
end
