class SessionsController < DeviseTokenAuth::SessionsController
  def render_create_success
    render json: @resource, serializer: Api::V1::UserSerializer
  end
end
