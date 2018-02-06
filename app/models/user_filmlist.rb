class UserFilmlist < ApplicationRecord
  belongs_to :user
  belongs_to :admin_movie
end
