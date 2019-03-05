class AddDescriptionToGenre < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_genres, :description, :text
  end
end
