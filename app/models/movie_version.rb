class MovieVersion < ApplicationRecord
  belongs_to :s3_multipart_upload, :class_name => "S3Multipart::Upload", optional: true
  # TODO: convert to polymorphic association to handle Movie / Episode
  belongs_to :admin_movie, class_name: 'Movie', foreign_key: "movie_id", optional: true
end
