class AddDetailToUserPaymentMethod < ActiveRecord::Migration[5.1]
  def change
    add_reference :user_payment_methods, :billing_plan, foreign_key: true
    add_column :user_payment_methods, :status, :string
  end
end
