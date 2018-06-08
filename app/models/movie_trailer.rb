class MovieTrailer < ApplicationRecord
  belongs_to :movie, :foreign_key => 'admin_movie_id'
end
