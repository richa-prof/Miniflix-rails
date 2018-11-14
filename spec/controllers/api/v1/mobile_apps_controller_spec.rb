require 'rails_helper'

RSpec.describe Api::V1::MobileAppsController, type: :controller do
  describe "GET share_app_link" do
    it "should return json response with 200 status code" do

      service_obj = TwilioService.new("123", "Download the app now to watch unlimited short films! ")
      expect(TwilioService).to receive(:new).with('123', "Download the app now to watch unlimited short films! ").and_return(service_obj)
      expect(service_obj).to receive(:call).and_return({ success: true, message: "Download link successfully sent to your phone number" })

      get :share_app_link, params: { phone_number: "123" }
      response_body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response_body.symbolize_keys).to eq({ success: true, message: "Download link successfully sent to your phone number" })
    end
  end
end
