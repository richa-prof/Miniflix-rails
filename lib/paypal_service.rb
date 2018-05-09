module Paypal
  class BillingPlanRequest
    def self.paypal_request_send(url, request_type, access_token, data, token=nil)
      url += "/#{token}"
      billing_plans_uri = URI.parse(url)
      billing_plans_request =  eval("Net::HTTP::#{request_type.camelcase}").new(billing_plans_uri)
      billing_plans_request.content_type = "application/json"
      billing_plans_request["Authorization"] = "Bearer #{access_token}"
      billing_plans_request.body = data
      billing_plans_response = Net::HTTP.start(billing_plans_uri.hostname, billing_plans_uri.port, use_ssl: billing_plans_uri.scheme == "https") do |http|
        http.request(billing_plans_request)
      end
       puts "Paypal response code #{billing_plans_response.code} \n\n paypal response body #{billing_plans_response.body}"
      billing_plans_response
    end
  end
end
