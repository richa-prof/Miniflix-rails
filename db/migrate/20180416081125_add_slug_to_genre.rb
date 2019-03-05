class AddSlugToGenre < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_genres, :slug, :string
  end
end
