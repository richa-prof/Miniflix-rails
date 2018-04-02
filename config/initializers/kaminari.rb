# After installing ActiveAdmin
# If we use will_paginate in our app, we need to configure an initializer for Kaminari
# to avoid conflicts.

Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end