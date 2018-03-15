class Api::V1::TokenValidationsController < DeviseTokenAuth::TokenValidationsController
  include Api::V1::Concerns::UserSerializeDataConcern
  def render_validate_token_success
      render json: {
        success: true,
        user: serialize_user
      }
  end
end
