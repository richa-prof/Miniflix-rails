class Api::V1::UserEmailNotificationSerializer < ActiveModel::Serializer
  attributes :id, :product_updates, :films_added, :special_offers_and_promotions, :better_product, :do_not_send
end
