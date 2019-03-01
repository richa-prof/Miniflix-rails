class ChangeColumnNameToBackgroundImage < ActiveRecord::Migration[5.2]
  def change
    rename_column :background_images, :backaground_image, :image_file
  end
end
