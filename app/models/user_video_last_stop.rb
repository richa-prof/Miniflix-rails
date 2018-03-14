class UserVideoLastStop < ApplicationRecord
  belongs_to :role, polymorphic: true
  belongs_to :movie, foreign_key: :admin_movie_id

  validates_presence_of :last_stopped, :total_time, :watched_percent
  #callback
  before_validation :save_watched_percent_of_video


  def remaining_time
    Time.at(calculate_remaining_time_in_sec).utc.strftime("%H:%M:%S")
  end

  private

  def save_watched_percent_of_video
    self.watched_percent = ((last_stopped.to_i * 100)/total_time.to_i) if (total_time && last_stopped)
  end

  def calculate_remaining_time_in_sec
     (total_time - last_stopped).round
  end
end
