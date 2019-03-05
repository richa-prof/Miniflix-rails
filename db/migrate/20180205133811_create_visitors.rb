class CreateVisitors < ActiveRecord::Migration[5.1]
  def change
    create_table :visitors do |t|
      t.string :device_id
      t.timestamps
    end
  end
end
