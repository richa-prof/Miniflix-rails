class PaypalAccessToken < ApplicationRecord
  self.table_name = 'admin_paypal_access_tokens'

  before_create  :destroy_expired_access_token

  # ======= Related to mobile API's START =======

  def self.fetch_paypal_access_token
    uri = URI(ENV["PAYPAL_TOKEN_URL"])
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV['PAYPAL_CLIENT_ID'], ENV['PAYPAL_CLIENT_SECRET'])
    request["Accept"] = "application/json" # need to ask
    request["Accept-Language"] = "en_US"
    request.set_form_data(
      "grant_type" => "client_credentials",
    )
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end
    puts "Paypal response code --> #{response.code} "
    if response.code == "200"
      token_response_json = JSON.parse(response.body)
      mode = (Rails.env == "production") ? "live" : "sandbox"
      PaypalAccessToken.create(:access_token => token_response_json['access_token'], :mode => mode, :grant_type => "client_credentials")
      puts "#{token_response_json['access_token']}"
      token_response_json['access_token']
    else
      nil
    end
  end

  private

  def destroy_expired_access_token
    PaypalAccessToken.destroy_all
  end

  # ======= Related to mobile API's END =======
end
