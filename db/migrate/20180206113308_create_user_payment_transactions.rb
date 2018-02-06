class CreateUserPaymentTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_payment_transactions do |t|
      t.references :user_payment_method, foreign_key: true, index: true
      t.datetime :payment_date
      t.datetime :payment_expire_date
      t.string :transaction_id
      t.float :amount
      t.timestamps
    end
  end
end
