require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      user = User.create
      sign_in user
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
