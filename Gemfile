source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use sqlite3 as the database for Active Record
gem 'mysql2'
#authorization
gem 'devise_token_auth'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'mandrill-api'

#Rack Middleware for handling Cross-Origin Resource Sharing (CORS), which makes cross-origin AJAX possible.
gem 'rack-cors', :require => 'rack/cors'


# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
#for attribute encryption - saving card details
gem "attr_encrypted"
gem 'twilio-ruby', '~> 5.6.3'
gem "figaro"
#for pagination
gem 'will_paginate', '~> 3.1.0'
#======set up for image and file =====================
#way to upload files
gem 'carrierwave', '~> 1.0'
#for storing file to s3
gem 'fog'
gem 'mini_magick'

gem 'active_model_serializers', '~> 0.10.7'
#social authentication
gem 'omniauth-facebook'
gem 'omniauth-twitter'

#for shorten url and tracking
gem 'bitly'

#friendly id for url
gem 'friendly_id', '~> 5.2.3'

#valiation for phone number
gem 'phony_rails'

#sidekiq
gem 'sidekiq'

# For witing Cron jobs
gem 'whenever', require: false

# For Sending notifications to Android and iOS devices via Firebase Cloud Messaging.
gem 'fcm'

gem 'aws-s3'
gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem "rspec-rails"
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'
  gem 'database_cleaner'
  gem 'shoulda-callback-matchers'
  gem 'simplecov', require: false
  gem 'pry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  #for mailing
  gem 'letter_opener'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-faster-assets'
  gem 'capistrano-rails-collection'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
