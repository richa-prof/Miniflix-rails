class CreateSeasons < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.references :admin_serial, foreign_key: true
      t.integer :season_number
    end
  end
end
