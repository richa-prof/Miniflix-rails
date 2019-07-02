class OwnFilm < ApplicationRecord
  belongs_to :film, polymorphic: true # Movie or Serial
  belongs_to :user
end
