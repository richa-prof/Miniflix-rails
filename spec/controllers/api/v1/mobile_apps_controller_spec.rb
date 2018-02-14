require 'rails_helper'

RSpec.describe Api::V1::MobileAppsController, type: :controller do
  describe "GET share_app_link" do
    it "should return json response with 200 status code" do

      service_obj = TwilioService.new("123")
      expect(TwilioService).to receive(:new).with('123').and_return(service_obj)
      expect(service_obj).to receive(:call).and_return({ success: true, success_msg: "successfully sent" })

      get :share_app_link, params: { phone_number: "123" }
      response_body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response_body.symbolize_keys).to eq({ success: true, success_msg: "successfully sent" })
    end
  end
end
