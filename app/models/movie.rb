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
  has_many :movie_versions, dependent: :destroy

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

  # ======= Related to mobile API's start =======
  def as_json(options=nil)
    case options
    when "full_movie_detail"
      return super(except: [:created_at, :updated_at, :version_file, :uploader, :s3_multipart_upload_id, :admin_genre_id]).merge(movie_screenshot: movie_screenshot_list, captions: self.movie_captions.map(&:as_json), film_video: fetch_movie_urls, genre_name: genre_name)
    when "genre_wise_list"
      return super(only: [:id, :name]).merge(movie_screenshot: movie_screenshot_list)
    else
      movie_detail =  super(only: [:id, :name, :title, :description, :language, :video_duration]).merge(film_video: fetch_movie_urls, genre_name: genre_name, movie_screenshot: movie_screenshot_list)
      movie_detail.merge!(last_stopped: fetch_last_stop(options)) if options.present?
      return movie_detail
    end
  end

  def fetch_movie_urls
    movie_urls = {}
    movie_urls[:hls] = "https://s3-us-west-1.amazonaws.com/#{ENV['S3_OUTPUT_BUCKET']}/#{version_file}"
    self.movie_versions.each do |version|
      movie_urls["video_"+version.resolution.to_s]  = "https://s3-us-west-1.amazonaws.com/#{ENV['S3_INPUT_BUCKET']}/#{version.film_video}"
    end
    movie_urls
  end

  def movie_screenshot_list
    movie_thumbnail = self.movie_thumbnail
    {
      original: image_url(movie_thumbnail.movie_screenshot_1.carousel_thumb.path),
      thumb330: image_url(movie_thumbnail.thumbnail_screenshot.carousel_thumb.path),
      thumb640: image_url(movie_thumbnail.thumbnail_640_screenshot.carousel_thumb.path)
    }
  end

  def image_url(path)
    'https://' +  ENV['Image_url'] +'/'+ path if path.present?
  end

  def fetch_last_stop(user)
    user_video_last_stop = user.user_video_last_stops.find_by(admin_movie_id: self.id)
    user_video_last_stop.present? ? user_video_last_stop.last_stopped : 0
  end
  # ======= Related to mobile API's start =======

  private
  def create_bitly_url
    bitly = Bitly.client.shorten(movie_show_url)
    self.bitly_url = bitly.short_url
  end

  def movie_show_url
     "#{ENV['Host']}/movies/#{self.slug}"
  end

end
