class CreateBillingPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_plans do |t|
      t.string  :name
      t.string  :description
      t.float :amount
      t.string  :currency
      t.string  :interval
      t.integer :trial_days
      t.string  :stripe_plan_id
      t.timestamps
    end
  end
end
