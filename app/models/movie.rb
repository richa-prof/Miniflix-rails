class Movie < ApplicationRecord
  self.table_name = "admin_movies"
  PER_PAGE = 6

  # Association
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"
  has_one :movie_thumbnail, dependent: :destroy, foreign_key: "admin_movie_id"

  #Scopes
  scope :featured, -> {where(is_featured_film: true)}

  #deligates
  delegate :name, to: :genre, prefix: :genre,  allow_nil: true

  self.per_page = PER_PAGE

  #instance method
  def hls_movie_url
    "https://s3-us-west-1.amazonaws.com/#{ENV['S3_OUTPUT_BUCKET']}/#{version_file}"
  end
end
