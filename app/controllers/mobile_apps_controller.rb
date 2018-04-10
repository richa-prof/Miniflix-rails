class MobileAppsController < ApplicationController

  def send_download_link
    message = "Download the app now to watch unlimited short films! #{ENV['smart_url']}"
    begin
      TwilioService.new(params[:number], message).call();

      response = { status: "success",
                   message: "Download link successfully send to your contact number."
                 }

    rescue Exception => e
      response = { status: "error",
                   message: e.message
                  }
    end

    render :json => response
  end
end
