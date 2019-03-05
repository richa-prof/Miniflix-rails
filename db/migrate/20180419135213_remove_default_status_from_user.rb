class RemoveDefaultStatusFromUser < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:users, :subscription_plan_status, nil)
  end
end
