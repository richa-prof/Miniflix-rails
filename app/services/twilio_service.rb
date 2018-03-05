class TwilioService

  def initialize(phone_number)
    @phone_number = phone_number
  end

  def call
    send_twilio_message(@phone_number)
  end

  private
    def send_twilio_message(phone_number)
      begin
        TWILIO.api.account.messages.create(
          from: ENV['TWILIO_PHONE_NUMBER'],
          to: phone_number,
          body: "Download the app now to watch unlimited short films! #{ENV['smart_url']}"
        )
        { success: true, message: 'Download link send successfully.' }
      rescue Twilio::REST::RestError => error
        { success: false, message: error.message }
      end
    end
end
