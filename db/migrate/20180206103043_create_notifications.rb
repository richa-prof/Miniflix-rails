class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.integer :admin_movie_id, foreign_key: true, index: true
      t.integer :user_id, foreign_key: true, index: true
      t.string   :message
      t.timestamps
    end
  end
end
