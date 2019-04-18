class AddReferencesToAdminMovieThumbnails < ActiveRecord::Migration[5.1]
  def change
    add_reference :admin_movie_thumbnails, :admin_serial, foreign_key: true, type: :int
  end
end
