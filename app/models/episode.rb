class Episode < ApplicationRecord
  self.table_name = 'admin_episodes'

  # CONSTANT STARTS
  PER_PAGE = 6

  # Ref.: https://github.com/norman/friendly_id
  extend FriendlyId
  friendly_id :name, use: :slugged

  # ASSOCIATIONS
  belongs_to :season, class_name: "Season", foreign_key: "season_id"
  has_many :movies, dependent: :destroy, foreign_key: "episode_id"

  class << self
    def search(search_query)
      key = "%#{search_query}%"
      Episode.where('name LIKE :search OR title LIKE :search', search: key).order(:name)
    end
  end
  
  def season_number
    season.season_number
  end

  def video_duration
    movies.pluck(:video_duration).sum
  end

  def last_stopped
    #movies.user_video_last_stops
  end

  def has_trailer?
    movies&.first&.trailer&.file&.present?
  end

  # ======= Related to mobile API =======

  def viewed_by_user?(user_id)
    UserFilmlist.where("admin_movie_id IN :ids AND user_id = :user_id", ids: movies.pluck(:id), user_id: user_id).present?
  end

  def as_json(user, format=nil)
    return super(except: [:created_at, :updated_at, :admin_season_id]).merge!(last_stopped: fetch_last_stop(user))
  end

  def fetch_last_stop(user)
    last_stopped_movie =  user.user_video_last_stops.where("admin_movie_id in :ids", ids: movies.pluck(:id)).order(:updated_at).desc
    last_stopped_movie&.id
  end

  private

end
