class CreateAdminGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_genres do |t|
      t.string :name
      t.string :color
      t.timestamps
    end
  end
end
