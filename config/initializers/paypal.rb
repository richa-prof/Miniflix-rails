require "paypal/recurring"

PayPal::Recurring.configure do |config|
  config.sandbox = Rails.env.production? ? false : true
  config.username = ENV['Paypal_Username']
  config.password = ENV['Paypal_Password']
  config.signature = ENV['Paypal_signature']
end
