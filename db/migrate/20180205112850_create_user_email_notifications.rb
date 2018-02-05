class CreateUserEmailNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :user_email_notifications do |t|
      t.references :user, foreign_key: true, index: true
      t.boolean    :product_updates, default: false
      t.boolean    :films_added, default: false
      t.boolean    :special_offers_and_promotions, default: false
      t.boolean    :better_product, default: false
      t.boolean    :do_not_send, default: false
      t.timestamps
    end
  end
end
