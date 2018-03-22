class Api::V1::ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery prepend: true

  rescue_from 'ActiveRecord::RecordNotFound' do |exception|
    render json: {success: false, error_message: exception.message}
  end

end
