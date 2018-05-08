class Genre < ApplicationRecord
  self.table_name = "admin_genres"
  PER_PAGE = 3

  # ASSOCIATIONS
  has_many :movies, dependent: :destroy, foreign_key: "admin_genre_id"

  #Friendly id
  extend FriendlyId
  friendly_id :name, use: :slugged
  # Genre.find_each(&:save)

  # VALIDATIONS
  validates_presence_of :name, :color
  validates :name, uniqueness: true

  #per_page genre on request from react side
  self.per_page = PER_PAGE
end
