class ChangeTotalTimeToBeFloatInUserVideoLastStops < ActiveRecord::Migration[5.1]
  def change
    change_column :user_video_last_stops, :total_time, :float
  end
end
