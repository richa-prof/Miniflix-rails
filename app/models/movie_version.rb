class MovieVersion < ApplicationRecord
  belongs_to :s3_multipart_upload, :class_name => "S3Multipart::Upload"
  belongs_to :admin_movie, class_name: "Admin::Movie", foreign_key: "movie_id"
end
