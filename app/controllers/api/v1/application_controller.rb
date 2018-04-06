class Api::V1::ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery prepend: true
  before_action :valid_client_request?

  rescue_from 'ActiveRecord::RecordNotFound' do |exception|
    render json: {success: false, error_message: exception.message}
  end

  def valid_client_request?
    unless request.headers['HTTP-X-CLIENT-TOKEN'] ==  ENV['HTTP_X_CLIENT_TOKEN']
      render json: {message: 'You are not authorize to access this request'}, status: :forbidden and return
    end
  end

end
