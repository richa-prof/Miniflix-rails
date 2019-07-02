class SerialThumbnail < ApplicationRecord
  self.table_name = "admin_serial_thumbnails"
  belongs_to :serial, :foreign_key => 'admin_serial_id'

  mount_uploader :serial_screenshot_1, SerialThumbnailUploader
	mount_uploader :serial_screenshot_2, SerialThumbnailUploader
	mount_uploader :serial_screenshot_3, SerialThumbnailUploader
	mount_uploader :thumbnail_screenshot, SerialThumbnailUploader
	mount_uploader :thumbnail_640_screenshot, SerialThumbnailUploader
  mount_uploader :thumbnail_800_screenshot, SerialThumbnailUploader


  def screenshot_urls_map
    {
      original: image_url(serial_screenshot_1.carousel_thumb.path).to_s,
      thumb330: image_url(thumbnail_screenshot.carousel_thumb.path).to_s,
      thumb640: image_url(thumbnail_640_screenshot.path).to_s,
      thumb800: thumb_800_url.to_s
    }
  end

  def thumb_800_url
    target_path = thumbnail_800_screenshot.try(:path)
    if target_path.present?
      return image_url(target_path)
    end
    thumbnail_800_screenshot_default_url
  end

  def thumbnail_800_screenshot_default_url
    dir_path = ActionController::Base.helpers.asset_path('admin/default_thumb800.jpg')
    "#{ENV['RAILS_HOST']}/#{dir_path}"
  end

  def image_url(path)
    CommonHelpers.cloud_front_url(path)
  end

end
