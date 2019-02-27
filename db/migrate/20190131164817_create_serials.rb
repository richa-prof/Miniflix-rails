class CreateSerials < ActiveRecord::Migration[5.1]
  def change
    create_table :serials do |t|
      t.string :title, null: false
      #t.date :year
      #t.references :admin_genre, foreign_key: true

      t.timestamps
    end
  end
end
