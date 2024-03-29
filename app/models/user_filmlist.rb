class UserFilmlist < ApplicationRecord
  belongs_to :user
  # FIXME - use polymorphic association?
  belongs_to :movie, foreign_key: "admin_movie_id", optional: true
  belongs_to :episode, foreign_key: "admin_movie_id", optional: true

  #validation for uniq movie could be added by user in add_to_playlist
  validates_uniqueness_of :user_id, scope: :admin_movie_id, messsage: "Movie already added in playlist"

end
