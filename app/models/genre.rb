class Genre < ApplicationRecord
  self.table_name = "admin_genres"

  #Association
  has_many :movies, dependent: :destroy, foreign_key: "admin_genre_id"

end
