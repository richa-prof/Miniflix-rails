class ChangeUserVideoLastStops < ActiveRecord::Migration[5.1]
  def change
    rename_column :user_video_last_stops, :role_id, :watcher_id
    rename_column :user_video_last_stops, :role_type, :watcher_type
    add_index  :user_video_last_stops, [:watcher_type, :watcher_id]
  end
end
