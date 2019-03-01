class CreateSerials < ActiveRecord::Migration[5.2]
  def change
    create_table :serials do |t|
      t.string :title, null: false
      t.date :year
      t.integer :admin_genre_id, foreign_key: true
      t.timestamps
    end
  end
end
