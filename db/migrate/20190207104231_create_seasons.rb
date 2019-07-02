class CreateSeasons < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.integer :admin_serial_id, foreign_key: true
      t.integer :season_number
    end
  end
end
