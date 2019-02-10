class Serial < ApplicationRecord
  self.table_name = 'admin_serials'
  has_many :seasons, dependent: :destroy, foreign_key: "admin_serial_id"
  has_one :movie_thumbnail, dependent: :destroy, foreign_key: "admin_serial_id"
  has_one :movie_trailer, dependent: :destroy, foreign_key: "admin_serial_id"
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"
  accepts_nested_attributes_for :movie_thumbnail

  extend FriendlyId
  friendly_id :title, use: :slugged

  scope :alfa_order, -> { order(:name) }


  def find_genre(id)
    admin_genre = Genre.find(id)
    admin_genre.name
  end

end
