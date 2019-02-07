class AddReferencesToAdminMovies < ActiveRecord::Migration[5.1]
  def change
    add_reference :admin_movies, :season, foreign_key: true
  end
end
