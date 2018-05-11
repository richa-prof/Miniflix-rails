class Visitor < ApplicationRecord
  has_many :user_video_last_stops, as: :role, dependent: :destroy
end
