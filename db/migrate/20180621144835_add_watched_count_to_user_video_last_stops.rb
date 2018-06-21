class AddWatchedCountToUserVideoLastStops < ActiveRecord::Migration[5.1]
  def change
  	add_column :user_video_last_stops, :watched_count, :integer, default: 0
  end
end
