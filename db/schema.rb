# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180621144835) do

  create_table "addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "city"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "admin_genres", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.text "description"
  end

  create_table "admin_movie_captions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "admin_movie_id"
    t.string "language"
    t.string "caption_file"
    t.boolean "status"
    t.boolean "is_default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_movie_id"], name: "index_admin_movie_captions_on_admin_movie_id"
  end

  create_table "admin_movie_thumbnails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "admin_movie_id"
    t.string "movie_screenshot_1"
    t.string "movie_screenshot_2"
    t.string "movie_screenshot_3"
    t.string "thumbnail_screenshot"
    t.string "thumbnail_640_screenshot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "thumbnail_800_screenshot"
    t.index ["admin_movie_id"], name: "index_admin_movie_thumbnails_on_admin_movie_id"
  end

  create_table "admin_movies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "admin_genre_id"
    t.integer "s3_multipart_upload_id"
    t.string "name"
    t.string "title"
    t.text "description"
    t.string "film_video"
    t.string "video_type"
    t.string "video_size"
    t.string "video_format"
    t.string "directed_by"
    t.date "released_date"
    t.string "language"
    t.date "posted_date"
    t.string "star_cast"
    t.string "actors"
    t.boolean "downloadable"
    t.string "video_duration"
    t.string "uploader"
    t.string "festival_laureates"
    t.boolean "is_featured_film"
    t.string "version_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bitly_url"
    t.string "slug"
    t.index ["admin_genre_id"], name: "index_admin_movies_on_admin_genre_id"
    t.index ["s3_multipart_upload_id"], name: "index_admin_movies_on_s3_multipart_upload_id"
  end

  create_table "admin_paypal_access_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "access_token"
    t.string "mode"
    t.string "grant_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_recurring_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "description"
    t.string "plan_type"
    t.string "payment_def_name"
    t.string "payment_def_type"
    t.string "payment_def_frequency"
    t.string "payment_def_frequency_interval"
    t.string "payment_def_amount"
    t.string "payment_def_currency"
    t.string "payment_def_cycles"
    t.string "merchant_setup_fee_amt"
    t.string "merchant_setup_fee_currency"
    t.string "return_url"
    t.string "cancel_url"
    t.string "auto_bill_amount"
    t.string "initial_fail_amount_action"
    t.string "max_fail_attempts"
    t.string "plan_id"
    t.string "plan_for"
    t.string "stripe_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "background_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "image_file"
    t.boolean "is_set"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "description"
    t.float "amount", limit: 24
    t.string "currency"
    t.string "interval"
    t.integer "trial_days"
    t.string "stripe_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blog_subscribers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "email"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blogs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "body"
    t.string "featured_image"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.text "description"
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "ckeditor_assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "body"
    t.string "commenter"
    t.integer "user_id"
    t.bigint "blog_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commenter_email"
    t.index ["blog_id"], name: "index_comments_on_blog_id"
  end

  create_table "contact_us", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "email"
    t.string "school"
    t.string "occupation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_user_replies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "contact_us_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_us_id"], name: "index_contact_user_replies_on_contact_us_id"
  end

  create_table "free_members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "likes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.bigint "blog_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_id"], name: "index_likes_on_blog_id"
  end

  create_table "logged_in_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.string "device_type"
    t.string "device_token"
    t.string "notification_from"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_logged_in_users_on_user_id"
  end

  create_table "mailchimp_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "list_id"
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_trailers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "file"
    t.integer "s3_multipart_upload_id"
    t.bigint "admin_movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uploader"
    t.index ["admin_movie_id"], name: "index_movie_trailers_on_admin_movie_id"
    t.index ["s3_multipart_upload_id"], name: "index_movie_trailers_on_s3_multipart_upload_id"
  end

  create_table "movie_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "movie_id"
    t.integer "s3_multipart_upload_id"
    t.string "uploader"
    t.string "film_video"
    t.string "video_size"
    t.string "resolution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_versions_on_movie_id"
    t.index ["s3_multipart_upload_id"], name: "index_movie_versions_on_s3_multipart_upload_id"
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "admin_movie_id"
    t.bigint "user_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_movie_id"], name: "index_notifications_on_admin_movie_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "s3_multipart_uploads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "location"
    t.string "upload_id"
    t.string "key"
    t.string "name"
    t.string "uploader"
    t.integer "size"
    t.text "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seo_meta", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "seo_meta_id"
    t.string "seo_meta_type"
    t.string "browser_title"
    t.string "meta_keywords"
    t.text "meta_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_seo_meta_on_id"
    t.index ["seo_meta_id", "seo_meta_type"], name: "id_type_index_on_seo_meta"
  end

  create_table "social_media_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "facebook"
    t.string "twitter"
    t.string "google_plus"
    t.string "linkedin"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_social_media_links_on_user_id"
  end

  create_table "temp_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "registration_plan"
    t.string "email"
    t.string "name"
    t.string "password"
    t.string "sign_up_from"
    t.string "uid"
    t.string "provider"
    t.string "token"
    t.string "auth_token"
    t.string "image"
    t.string "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_email_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.boolean "product_updates", default: false
    t.boolean "films_added", default: false
    t.boolean "special_offers_and_promotions", default: false
    t.boolean "better_product", default: false
    t.boolean "do_not_send", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_email_notifications_on_user_id"
  end

  create_table "user_filmlists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "admin_movie_id"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_movie_id"], name: "index_user_filmlists_on_admin_movie_id"
    t.index ["user_id"], name: "index_user_filmlists_on_user_id"
  end

  create_table "user_payment_methods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "zip_code"
    t.string "payment_type", null: false
    t.string "old_card_number"
    t.integer "old_expiration_month"
    t.integer "old_expiration_year"
    t.integer "old_card_CVC"
    t.string "card_token"
    t.float "amount", limit: 24
    t.boolean "is_send_expiration_mail"
    t.datetime "payment_date"
    t.datetime "payment_expire_date"
    t.string "agreement_id"
    t.string "paypal_plan_id"
    t.string "encrypted_card_CVC"
    t.string "encrypted_card_CVC_iv"
    t.string "encrypted_card_number"
    t.string "encrypted_card_number_iv"
    t.string "encrypted_expiration_month"
    t.string "encrypted_expiration_month_iv"
    t.string "encrypted_expiration_year"
    t.string "encrypted_expiration_year_iv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "billing_plan_id"
    t.string "status"
    t.index ["billing_plan_id"], name: "index_user_payment_methods_on_billing_plan_id"
    t.index ["user_id"], name: "index_user_payment_methods_on_user_id"
  end

  create_table "user_payment_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_payment_method_id"
    t.datetime "payment_date"
    t.datetime "payment_expire_date"
    t.string "transaction_id"
    t.float "amount", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_payment_method_id"], name: "index_user_payment_transactions_on_user_payment_method_id"
  end

  create_table "user_video_last_stops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "admin_movie_id"
    t.integer "role_id"
    t.string "role_type"
    t.float "last_stopped", limit: 24
    t.integer "total_time"
    t.float "watched_percent", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "watched_count", default: 0
    t.index ["admin_movie_id"], name: "index_user_video_last_stops_on_admin_movie_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "image"
    t.string "email"
    t.string "registration_plan"
    t.string "phone_number"
    t.string "unconfirmed_phone_number"
    t.string "verification_code"
    t.string "sign_up_from"
    t.string "customer_id"
    t.string "subscription_id"
    t.datetime "cancelation_date"
    t.string "role", default: "User"
    t.string "subscription_plan_status"
    t.boolean "is_free", default: false
    t.text "receipt_data", limit: 4294967295
    t.datetime "expires_at"
    t.string "auth_token"
    t.text "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "migrate_user", default: false
    t.string "temp_password"
    t.string "slug"
    t.boolean "allow_password_change", default: false, null: false
    t.boolean "valid_for_thankyou_page", default: false
    t.string "token"
    t.boolean "battleship"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "visitors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "admin_movie_captions", "admin_movies"
  add_foreign_key "admin_movie_thumbnails", "admin_movies"
  add_foreign_key "admin_movies", "admin_genres"
  add_foreign_key "blogs", "users"
  add_foreign_key "comments", "blogs"
  add_foreign_key "contact_user_replies", "contact_us", column: "contact_us_id"
  add_foreign_key "likes", "blogs"
  add_foreign_key "logged_in_users", "users"
  add_foreign_key "movie_trailers", "admin_movies"
  add_foreign_key "notifications", "admin_movies"
  add_foreign_key "notifications", "users"
  add_foreign_key "social_media_links", "users"
  add_foreign_key "user_email_notifications", "users"
  add_foreign_key "user_filmlists", "admin_movies"
  add_foreign_key "user_filmlists", "users"
  add_foreign_key "user_payment_methods", "billing_plans"
  add_foreign_key "user_payment_methods", "users"
  add_foreign_key "user_payment_transactions", "user_payment_methods"
  add_foreign_key "user_video_last_stops", "admin_movies"
end
