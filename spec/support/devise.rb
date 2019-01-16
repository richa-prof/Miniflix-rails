RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  # Capybara
  config.include Warden::Test::Helpers

  config.after :each do
    Warden.test_reset!
  end
end

def authenticate_api(user)
  request.headers['authentication'] = user.update_auth_token
end