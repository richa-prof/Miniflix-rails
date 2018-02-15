class MovieCaption < ApplicationRecord
  self.table_name = "admin_movie_captions"

  #Association
  belongs_to :movie
end
