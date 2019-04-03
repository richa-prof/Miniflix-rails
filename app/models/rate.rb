class Rate < ApplicationRecord

  belongs_to :entity, polymorphic: true # User, Serial, Season, Movie

  validates_presence_of :price
end