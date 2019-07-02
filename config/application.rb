require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Miniflix
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.action_mailer.default_url_options = { host:  ENV['RAILS_HOST']}

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    #use sidekiq for active job
    config.autoload_paths += Dir[Rails.root.join('app','uploaders','multipart')]

    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.test_framework :rspec,
        :fixtures => true,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true

      g.fixture_replacement :factory_bot, :dir => "spec/factories"

    end

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
        :headers => :any,
        :expose => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
        :methods => [:get, :post, :options, :delete, :put, :patch]
      end
    end

    config.middleware.use(Rack::Tracker) do
      handler :facebook_pixel, { id: ENV['FACEBOOK_PIXEL_ID'] }
    end
  end
end
