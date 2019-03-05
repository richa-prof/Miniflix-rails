class RemoveNullFromUserPaymentMethod < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:user_payment_methods, :payment_date, true)
    change_column_null(:user_payment_methods, :payment_expire_date, true)
  end
end
