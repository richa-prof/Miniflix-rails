class MovieVersion < ApplicationRecord
  belongs_to :s3_multipart_upload, :class_name => "S3Multipart::Upload", optional: true
  belongs_to :admin_movie, class_name: 'Movie', foreign_key: "movie_id"
end
