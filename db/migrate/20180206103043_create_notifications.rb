class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.references :admin_movie, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.string   :message
      t.timestamps
    end
  end
end
