class Serial < ApplicationRecord
  self.table_name = 'admin_serials'
  has_many :seasons, dependent: :destroy, foreign_key: "admin_serial_id"
  has_one :serial_thumbnail, dependent: :destroy, foreign_key: "admin_serial_id"
  has_one :movie_trailer, dependent: :destroy, foreign_key: "admin_serial_id"
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"
  accepts_nested_attributes_for :serial_thumbnail

  extend FriendlyId
  friendly_id :title, use: :slugged

  scope :alfa_order, -> { order(:name) }


  def find_genre(id)
    genre = Genre.find(id)
    genre.name
  end

  def seasons_list
    season_numbers = self.seasons.pluck(:season_number)
    h = Hash.new
    arr = []
    season_numbers.each do |el|
      season = self.seasons.find_by(season_number: el)
      h[el] = season.episodes.count
    end
    arr << h
    return arr.first
  end

  def seasons_extended_list
    season_numbers = self.seasons.pluck(:season_number)
    h = Hash.new
    seasons.each do |season|
      h[season.season_number] = season.episodes.map {|ep| ep.to_json}
    end
    h
  end

  def screenshot_list
    out = {}
    episodes.each do |ep|
      out.merge!(ep.movie_thumbnail.screenshot_urls_map)
    end
    out
  end

  def episodes
    Episode.where("season_id in (:list)", list: seasons.pluck(:id))
  end

  def is_liked_by_user?(user)
    user.user_filmlists.where("admin_movie_id in (:list)", list: episodes.pluck(:id)).count > 0
  end

  def compact_response
    {
      id: id, 
      title: title, 
      year: year&.year, 
      genre_data: { 
        id: genre&.id, 
        name: genre&.name
      },
      seasons_data: seasons_list,
      screenshot: screenshot_list
    }
  end

  def formatted_response(user: nil, mode: nil)
    case mode
    when "short_serial_model"
      compact_response
    else
      {
        code: 1, # FIXME
        status: "Success", # FIXME
        data: compact_response.merge!(
          director: directed_by, 
          description: description, 
          audio: language,
          isLiked: is_liked_by_user?(user),
          stars: star_cast,
          seasons: seasons_extended_list)
      }
    end
  end
end
