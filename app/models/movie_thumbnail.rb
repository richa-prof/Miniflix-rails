class MovieThumbnail < ApplicationRecord
  self.table_name = "admin_movie_thumbnails"
  belongs_to :admin_movies
end
