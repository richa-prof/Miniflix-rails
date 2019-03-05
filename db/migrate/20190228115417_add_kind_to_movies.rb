class AddKindToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_movies, :kind, :string, default: 'movie'
    add_index :admin_movies, :kind
  end
end
