class AddDetailToUserPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    add_column :user_payment_methods_id, :billing_plan, foreign_key: true, type: :integer
    add_column :user_payment_methods, :status, :string
  end
end
