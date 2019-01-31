class Serial < ApplicationRecord
  self.table_name = 'admin_serials'
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"


  def find_genre(id)
    admin_genre = Genre.find(id)
    admin_genre.name
  end

end
