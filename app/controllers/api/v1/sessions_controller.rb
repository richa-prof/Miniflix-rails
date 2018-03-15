class Api::V1::SessionsController < DeviseTokenAuth::SessionsController
  include Api::V1::Concerns::UserSerializeDataConcern

  def render_create_success
    render json: {
      success: true,
      user:   serialize_user
    }
  end
end
