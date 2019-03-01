class AddDefaultValueToIsFree < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :is_free, :boolean, default: false
  end
end
