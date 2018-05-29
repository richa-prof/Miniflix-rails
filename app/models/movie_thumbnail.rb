class MovieThumbnail < ApplicationRecord
  self.table_name = "admin_movie_thumbnails"
  belongs_to :movie, :foreign_key => 'admin_movie_id'

  mount_uploader :movie_screenshot_1, MovieThumbnailUploader
	mount_uploader :movie_screenshot_2, MovieThumbnailUploader
	mount_uploader :movie_screenshot_3, MovieThumbnailUploader
	mount_uploader :thumbnail_screenshot, MovieThumbnailUploader
	mount_uploader :thumbnail_640_screenshot, MovieThumbnailUploader
  mount_uploader :thumbnail_800_screenshot, MovieThumbnailUploader

  def cloud_front_url(path)
    # ENV['cloud_front_url'] + path
    'https://' +  ENV['cloud_front_url'] +'/'+ path
  end

  def thumb_800_url
    target_path = thumbnail_800_screenshot.try(:path)
    if target_path.present?
      return cloud_front_url(target_path)
    end

    thumbnail_800_screenshot_default_url
  end

  def thumbnail_800_screenshot_default_url
    dir_path = ActionController::Base.helpers.asset_path('admin/default_thumb800.jpg')

    "#{ENV['RAILS_HOST']}/#{dir_path}"
  end
end
