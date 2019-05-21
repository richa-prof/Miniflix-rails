class AddReferencesToAdminMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_movies, :season_id, :integer, foreign_key: true
  end
end
