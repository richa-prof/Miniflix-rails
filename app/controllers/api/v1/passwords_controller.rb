class Api::V1::PasswordsController < DeviseTokenAuth::PasswordsController
  include Api::V1::Concerns::UserSerializeDataConcern
  def render_update_success
      render json: {
        success: true,
        user: serialize_user,
        message: I18n.t("devise_token_auth.passwords.successfully_updated")
      }
  end
end
