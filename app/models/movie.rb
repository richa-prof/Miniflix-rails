class Movie < ApplicationRecord
  self.table_name = "admin_movies"
  PER_PAGE = 6
  SHARE_ON = ['facebook', 'twitter']

  #friendly id
  extend FriendlyId
  friendly_id :name, use: :slugged
  # To update the slug of old records please run below query.
  # Movie.find_each(&:save)

  # Association
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"
  has_one :movie_thumbnail, dependent: :destroy, foreign_key: "admin_movie_id"
  has_many :notifications, dependent: :destroy, foreign_key: "admin_movie_id"
  has_many :user_filmlists, dependent: :destroy, foreign_key: "admin_movie_id"
  has_many :user_video_last_stops, dependent: :destroy, foreign_key: "admin_movie_id"
  has_many :movie_captions, dependent: :destroy, foreign_key: "admin_movie_id"

  #callback
  before_save :create_bitly_url, if: -> {slug_changed?}


  #Scopes
  scope :featured, -> {where(is_featured_film: true)}

  #deligates
  delegate :name, to: :genre, prefix: :genre,  allow_nil: true

  self.per_page = PER_PAGE

  #instance method
  def hls_movie_url
    "https://s3-us-west-1.amazonaws.com/#{ENV['S3_OUTPUT_BUCKET']}/#{version_file}"
  end

  def self.search(search_key)
    key = "%#{search_key}%"
    Movie.where('name LIKE :search OR title LIKE :search OR description LIKE :search or festival_laureates LIKE :search or actors LIKE :search', search: key).order(:name)
  end

  def active_movie_captions
    self.movie_captions.active_caption
  end

  private
  def create_bitly_url
    bitly = Bitly.client.shorten(movie_show_url)
    self.bitly_url = bitly.short_url
  end

  def movie_show_url
     "#{ENV['Host']}/movies/#{self.slug}"
  end

end
