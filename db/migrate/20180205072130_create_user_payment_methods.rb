class CreateUserPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :user_payment_methods do |t|
      t.references :user, foreign_key: true, index:true, type: :integer
      t.string     :first_name
      t.string     :last_name
      t.integer    :zip_code
      t.string     :payment_type, null: false
      t.string     :old_card_number
      t.integer    :old_expiration_month
      t.integer    :old_expiration_year
      t.integer    :old_card_CVC
      t.string     :card_token
      t.float      :amount
      t.boolean    :is_send_expiration_mail
      t.datetime   :payment_date, null: false
      t.datetime   :payment_expire_date, null: false
      t.string     :agreement_id
      t.string     :paypal_plan_id
      t.string     :encrypted_card_CVC
      t.string     :encrypted_card_CVC_iv
      t.string     :encrypted_card_number
      t.string     :encrypted_card_number_iv
      t.string     :encrypted_expiration_month
      t.string     :encrypted_expiration_month_iv
      t.string     :encrypted_expiration_year
      t.string     :encrypted_expiration_year_iv
      t.timestamps
    end
  end
end
