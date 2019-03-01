class CreateUserVideoLastStops < ActiveRecord::Migration[5.2]
  def change
    create_table :user_video_last_stops do |t|
      t.integer  :admin_movie_id, foreign_key: true, index: true
      t.integer  :role_id
      t.string   :role_type
      t.float    :last_stopped
      t.integer  :total_time
      t.float    :watched_percent
      t.timestamps
    end
  end
end
