class Api::V1::MobileAppsController < Api::V1::ApplicationController

  def share_app_link
    response = TwilioService.new(params[:phone_number]).call()
    render json: response
  end
end
