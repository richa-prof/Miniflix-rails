class CreateAdminMovieThumbnails < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_movie_thumbnails do |t|
      t.integer :admin_movie_id, foreign_key: true, index: true
      t.string  :movie_screenshot_1
      t.string  :movie_screenshot_2
      t.string  :movie_screenshot_3
      t.string  :thumbnail_screenshot
      t.string  :thumbnail_640_screenshot
      t.timestamps
    end
  end
end
