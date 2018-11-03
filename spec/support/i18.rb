Dir[Rails.root.join('spec/macros/**/*.rb')].each { |f| require f }
RSpec.configure do |config|
  Capybara.page.driver.header('HTTP_ACCEPT_LANGUAGE', 'en')
  Capybara.ignore_hidden_elements = false
  config.include AbstractController::Translation
  # config.raise_on_missing_translations = true
end
