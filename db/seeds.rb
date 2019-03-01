require 'factory_bot_rails'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.create!(provider: "email", uid: "belinskiy21@gmail.com", name: "Oleg", image: nil, email: "belinskiy21@gmail.com", registration_plan: "Annually", phone_number: "+48574256907", unconfirmed_phone_number: nil, verification_code: "2332", sign_up_from: "by_admin", customer_id: "1", subscription_id: "1", cancelation_date: nil, role: "admin", subscription_plan_status: "incomplete", is_free: true, receipt_data: nil, expires_at: nil, auth_token: "Odessey130$", created_at: "2018-12-26 20:41:18", updated_at: "2019-01-25 10:29:16", migrate_user: false, temp_password: nil, slug: "oleg", allow_password_change: true, valid_for_thankyou_page: true, token: nil, battleship: nil)
#
#
# Genre.create!(name: "Comedy",
#  color: "red",
#  slug: "slug",
#  description: "comedy")

serial = Serial.create!(title: "Friends",
 year: Date.parse('1998-08-20'),
 admin_genre_id: 1,
 directed_by: "Aston Martin",
 star_cast: "Jeniffer Aniston, Cortny Cox",
 description: "Serial about yung guys from New York",
 language: "English",
 slug: "friends")

 Season.create!(admin_serial_id: serial.id, season_number: 1)


if Rails.env.development?
  FactoryBot.create(:user, role: 'Admin', email: 'admin@admin.com', password: 'admin@123')
end

