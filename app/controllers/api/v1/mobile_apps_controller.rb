class Api::V1::MobileAppsController < Api::V1::ApplicationController

  def share_app_link
    message = "Download the app now to watch unlimited short films! #{ENV['smart_url']}"
    response = TwilioService.new(params[:phone_number], message).call()
    response[:message] = "Download link successfully sent to your phone number" if response[:success]
    render json: response
  end
end
