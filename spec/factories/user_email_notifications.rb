FactoryBot.define do
  factory :user_email_notification do
    product_updates true
    films_added true
    special_offers_and_promotions true
    better_product true
    do_not_send true
  end
end
