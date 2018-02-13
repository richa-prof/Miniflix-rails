#Twilio api for message sending
account_sid = Rails.application.secrets.TWILIO_ACCOUNT_SID
auth_token  = Rails.application.secrets.TWILIO_AUTH_TOKEN
TWILIO = Twilio::REST::Client.new(account_sid, auth_token)
