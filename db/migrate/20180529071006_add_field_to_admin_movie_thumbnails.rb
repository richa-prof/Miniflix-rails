class AddFieldToAdminMovieThumbnails < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_movie_thumbnails, :thumbnail_800_screenshot, :string
  end
end
