class UserVideoLastStop < ApplicationRecord
  belongs_to :role, polymorphic: true
  belongs_to :movie, foreign_key: :admin_movie_id

  #constants
  PER_PAGE = 10

  validates_presence_of :last_stopped, :total_time, :watched_percent
  #callback
  before_validation :save_watched_percent_of_video

  delegate :title, to: :movie, prefix: :movie,  allow_nil: true
  delegate :name, to: :movie, prefix: :movie,  allow_nil: true

  #pagination per page value
  self.per_page = PER_PAGE

  # ===== Class methods Start =====
  class << self
    def convert_time_to_seconds(duration)
      time = duration.split(':')
      seconds = 0
      if time.length == 3
        seconds += time[0].to_i * 3600
        seconds += time[1].to_i * 60
        seconds += time[2].to_i
      elsif time.length == 2
        seconds += time[0].to_i * 60
        seconds += time[1].to_i
      else
        seconds += time[0].to_i
      end
    end
  end
  # ===== Class methods End =====

  def remaining_time
    Time.at(calculate_remaining_time_in_sec).utc.strftime("%H:%M:%S")
  end

  # ======= Related to mobile API's START =======
  def time_left
    time_left_sec = (total_time - last_stopped).round
    if time_left_sec < 30
      if time_left_sec > 0
        time_left_sec.to_s+" sec left"
      else
        "watched"
      end
    else
      time_left = (time_left_sec/60.to_f).round
      time_left.to_s+" min left"
    end
  end

  def current_time
    # curr_hour = (last_stopped/3600.to_f).round
    # rem_sec = last_stopped%3600
    # curr_min = (rem_sec/60).floor
    # curr_sec = (rem_sec%60).round
    # curr_hour.to_s.rjust(2, '0')+":"+curr_min.to_s.rjust(2, '0')+":"+curr_sec.to_s.rjust(2, '0')
    last_stopped > 59 ? last_stopped > 3599 ? Time.at(last_stopped).utc.strftime("%H:%M:%S") : Time.at(last_stopped).utc.strftime("%M:%S") : Time.at(last_stopped).utc.strftime("%S")
  end

  def formated_updated_at
    updated_at.strftime("%Y-%m-%d'T'%H:%M:%S")
  end
  # ======= Related to mobile API's END =======

  private

  def save_watched_percent_of_video
    self.watched_percent = ((last_stopped.to_i * 100)/total_time.to_i) if (total_time && last_stopped)
  end

  def calculate_remaining_time_in_sec
     (total_time - last_stopped).round
  end
end
