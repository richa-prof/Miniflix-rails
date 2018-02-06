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

ActiveRecord::Schema.define(version: 20180205141330) do

  create_table "admin_genres", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "background_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "backaground_image"
    t.boolean "is_set"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "logged_in_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.string "device_type"
    t.string "device_token"
    t.string "notification_from"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_logged_in_users_on_user_id"
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
    t.datetime "payment_date", null: false
    t.datetime "payment_expire_date", null: false
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
    t.index ["user_id"], name: "index_user_payment_methods_on_user_id"
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
    t.string "subscription_plan_status", default: "Activate"
    t.boolean "is_free"
    t.text "receipt_data"
    t.datetime "expires_at"
    t.string "auth_token"
    t.text "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "contact_user_replies", "contact_us", column: "contact_us_id"
  add_foreign_key "logged_in_users", "users"
  add_foreign_key "user_email_notifications", "users"
  add_foreign_key "user_payment_methods", "users"
end
