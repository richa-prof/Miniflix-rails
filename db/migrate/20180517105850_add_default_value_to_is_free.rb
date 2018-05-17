class AddDefaultValueToIsFree < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :is_free, :boolean, default: false
  end
end
