class CreateOwnFilms < ActiveRecord::Migration[5.1]
  def change
    create_table :own_films do |t|
      t.integer  :user_id, foreign_key: true, index: true
      t.integer  :film_id
      t.string   :film_type
      t.timestamps
    end
    add_index  :own_films, [:film_type, :film_id]
  end
end
