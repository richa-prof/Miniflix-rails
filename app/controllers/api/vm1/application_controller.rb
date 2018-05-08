class Api::Vm1::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead. OR  :exception
  protect_from_forgery with: :null_session

  def api_user
    User.find_by_id_and_auth_token(params[:user_id], request.headers['authentication']) if params[:user_id] && request.headers['authentication']
  end

  private

  def authenticate_api
    render json: {code: '-1', status: 'unauthorize_request'} and return if api_user.nil?
  end

  def authenticate_according_to_devise
    unless request.headers['deviceType'] == "ios"
       authenticate_api
    end
  end
end
