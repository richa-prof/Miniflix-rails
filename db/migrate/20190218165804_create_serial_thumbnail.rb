class CreateSerialThumbnail < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_serial_thumbnails do |t|
      t.integer :admin_serial_id, foreign_key: true
      t.string :serial_screenshot_1
      t.string :serial_screenshot_2
      t.string :serial_screenshot_3
      t.string :thumbnail_screenshot
      t.string :thumbnail_640_screenshot
      t.string :thumbnail_800_screenshot
    end
  end
end
