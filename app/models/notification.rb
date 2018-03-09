class Notification < ApplicationRecord
  belongs_to :movie, foreign_key: "admin_movie_id"
  belongs_to :user

  #Pagination per page
  PER_PAGE = 10
  self.per_page = PER_PAGE

  delegate :name, to: :movie, prefix: :movie,  allow_nil: true
end
