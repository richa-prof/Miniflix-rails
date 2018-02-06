class MovieVersion < ApplicationRecord
  belongs_to :admin_movie, class_name: "Admin::Movie", foreign_key: "movie_id"
end
