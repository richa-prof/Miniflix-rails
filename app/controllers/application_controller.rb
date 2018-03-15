class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception,  unless: :api_request?

  def api_request?
    request.url.include?('api')
  end
end
