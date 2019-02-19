class SerialThumbnail < ApplicationRecord
  self.table_name = "admin_serial_thumbnails"
  belongs_to :serial, :foreign_key => 'admin_serial_id'

  mount_uploader :serial_screenshot_1, SerialThumbnailUploader
	mount_uploader :serial_screenshot_2, SerialThumbnailUploader
	mount_uploader :serial_screenshot_3, SerialThumbnailUploader
	mount_uploader :thumbnail_screenshot, SerialThumbnailUploader
	mount_uploader :thumbnail_640_screenshot, SerialThumbnailUploader
  mount_uploader :thumbnail_800_screenshot, SerialThumbnailUploader
end
