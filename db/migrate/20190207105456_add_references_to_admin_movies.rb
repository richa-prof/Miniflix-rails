class AddReferencesToAdminMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_movies_id, :season, foreign_key: true, type: :integer
  end
end
