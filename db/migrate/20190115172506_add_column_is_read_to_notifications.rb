class AddColumnIsReadToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :is_read, :boolean, default: false
  end
end
