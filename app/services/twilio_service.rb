class TwilioService

  def initialize(phone_number, message)
    @phone_number = phone_number
    @message = message
  end

  def call
    send_twilio_message(@phone_number, @message)
  end

  private
    def send_twilio_message(phone_number, message)
      begin
        TWILIO.api.account.messages.create(

          from: ENV['TWILIO_PHONE_NUMBER'],
          to: phone_number,
          body: message
        )
        { success: true}
      rescue Twilio::REST::RestError => error
        { success: false, message: error.message }
      end
    end
end
