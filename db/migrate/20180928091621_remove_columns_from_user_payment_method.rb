class RemoveColumnsFromUserPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_payment_methods, :first_name, :string
    remove_column :user_payment_methods, :last_name, :string
    remove_column :user_payment_methods, :zip_code, :integer
    remove_column :user_payment_methods, :old_card_number, :string
    remove_column :user_payment_methods, :old_expiration_month, :integer
    remove_column :user_payment_methods, :old_expiration_year, :integer
    remove_column :user_payment_methods, :old_card_CVC, :integer
    remove_column :user_payment_methods, :card_token, :string
    remove_column :user_payment_methods, :amount, :float
    remove_column :user_payment_methods, :payment_date, :datetime
    remove_column :user_payment_methods, :payment_expire_date, :datetime
    remove_column :user_payment_methods, :encrypted_card_CVC, :string
    remove_column :user_payment_methods, :encrypted_card_CVC_iv, :string
    remove_column :user_payment_methods, :encrypted_card_number, :string
    remove_column :user_payment_methods, :encrypted_card_number_iv, :string
    remove_column :user_payment_methods, :encrypted_expiration_month, :string
    remove_column :user_payment_methods, :encrypted_expiration_month_iv, :string
    remove_column :user_payment_methods, :encrypted_expiration_year, :string
    remove_column :user_payment_methods, :encrypted_expiration_year_iv, :string
  end
end
