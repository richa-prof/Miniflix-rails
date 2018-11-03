require 'rails_helper'

RSpec.describe Api::Vm1::UsersController, type: :controller do

  describe 'GET #check_email_exists' do
    let!(:users) { create_list(:user, 5) }

    subject { get :check_email_exists, params: params }

    before { subject }

    context 'user not exists' do
      let(:params) { { email: 'user@user.com' } }
      it { expect(response.body).to be_json_eql(false.to_json).at_path('exists') }
    end

    context 'user exists' do
      let(:params) { { email: users.first.email } }
      it { expect(response.body).to be_json_eql(true.to_json).at_path('exists') }
    end
  end
end
