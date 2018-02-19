class Genre < ApplicationRecord
  self.table_name = "admin_genres"
  PER_PAGE = 3

  #Association
  has_many :movies, dependent: :destroy, foreign_key: "admin_genre_id"

  #per_page genre on request from react side
  self.per_page = PER_PAGE
end
