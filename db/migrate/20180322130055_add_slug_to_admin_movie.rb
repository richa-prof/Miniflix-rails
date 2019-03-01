class AddSlugToAdminMovie < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_movies, :slug, :string
  end
end
