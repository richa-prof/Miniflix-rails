class AddMigrateFieldToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :migrate_user, :boolean, default: false
  end
end
