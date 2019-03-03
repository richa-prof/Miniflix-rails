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

  def serial_screenshot_list
    movie_thumbnail = self.movie_thumbnail
    movie_thumbnail.screenshot_urls_map if movie_thumbnail
  end

  def formatted_response(options=nil)
    case options
    when "short_serial_model"
      return { id: self.id, title: self.title, year: self.year.year, genre_data: { id: self.genre.id, name: self.genre.name}, seasons_data: self.seasons_list, screenshot:  self.serial_screenshot_list  }
    else
      serila_detail =  super(only: [:id, :name, :title, :description, :language, :admin_genre_id]).merge( genre: genre.name, movie_screenshot: movie_screenshot_list)
      return serila_detail
    end
  end

end
