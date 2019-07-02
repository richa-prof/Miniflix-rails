class Genre < ApplicationRecord
  self.table_name = "admin_genres"
  PER_PAGE = 3

  # Ref.: https://github.com/parndt/seo_meta
  is_seo_meta
  add_validations

  # ASSOCIATIONS
  has_many :movies, dependent: :destroy, foreign_key: "admin_genre_id"
  has_many :serials, dependent: :destroy, foreign_key: "admin_genre_id"

  #Friendly id
  extend FriendlyId
  friendly_id :name, use: :slugged
  # Genre.find_each(&:save)

  # VALIDATIONS
  validates_presence_of :name, :color
  validates :name, uniqueness: true

  #per_page genre on request from react side
  self.per_page = PER_PAGE

  # SCOPE
  scope :alfa_order, -> { order(:name) }

  def frontend_view_page_url
    "#{ENV['Host']}/genre/#{self.slug}"
  end
end
