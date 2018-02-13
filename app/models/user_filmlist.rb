class UserFilmlist < ApplicationRecord
  belongs_to :user
  belongs_to :admin_movie, class_name: "Admin::Movie"
end
