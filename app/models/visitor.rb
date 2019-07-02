class Visitor < ApplicationRecord
  has_many :user_video_last_stops, as: :recent_videos, dependent: :destroy
end
