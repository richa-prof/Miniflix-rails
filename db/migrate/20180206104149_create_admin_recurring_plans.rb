class CreateAdminRecurringPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_recurring_plans do |t|
      t.string   :name
      t.string   :description
      t.string   :plan_type
      t.string   :payment_def_name
      t.string   :payment_def_type
      t.string   :payment_def_frequency
      t.string   :payment_def_frequency_interval
      t.string   :payment_def_amount
      t.string   :payment_def_currency
      t.string   :payment_def_cycles
      t.string   :merchant_setup_fee_amt
      t.string   :merchant_setup_fee_currency
      t.string   :return_url
      t.string   :cancel_url
      t.string   :auto_bill_amount
      t.string   :initial_fail_amount_action
      t.string   :max_fail_attempts
      t.string   :plan_id
      t.string   :plan_for
      t.string   :stripe_plan_id
      t.timestamps
    end
  end
end


