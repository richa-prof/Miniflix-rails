class CreateBackgroundImages < ActiveRecord::Migration[5.2]
  def change
    create_table :background_images do |t|
      t.string :backaground_image
      t.boolean :is_set
      t.timestamps
    end
  end
end
