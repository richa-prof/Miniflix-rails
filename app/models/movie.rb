class Movie < ApplicationRecord
self.table_name = "admin_movies"

# Association
belongs_to :genre

#Scopes
scope :featured, -> {find_by(is_featured_film: true)}
end
