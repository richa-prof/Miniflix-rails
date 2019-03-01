class CreateUserPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_payment_transactions do |t|
      t.integer :user_payment_method_id, foreign_key: true, index: true
      t.datetime :payment_date
      t.datetime :payment_expire_date
      t.string :transaction_id
      t.float :amount
      t.timestamps
    end
  end
end
