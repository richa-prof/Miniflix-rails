# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('vendor')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

Rails.application.config.assets.precompile += %w(
  admin.js admin.css provider.js provider.css app_view.css app-payment.css ckeditor/* admin/bootstrap-fileupload.js android.js \
  admin/flot/jquery.flot.min.js admin/flot/jquery.flot.resize.min.js admin/flot/jquery.flot.pie.min.js \
  admin/flot/jquery.flot.categories.min.js vendor.js admin/upload_movies admin/series swagger_ui.css \
  swagger_ui_base.css swagger_ui_bundle.js swagger_ui_standalone_preset.js admin/movie_player_init.js
)

Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/  