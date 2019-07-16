class MovieThumbnail < ApplicationRecord
  self.table_name = "admin_movie_thumbnails"
  belongs_to :movie, :foreign_key => 'admin_movie_id'

  #validations
  validates_presence_of :movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3

  mount_uploader :movie_screenshot_1, MovieThumbnailUploader
	mount_uploader :movie_screenshot_2, MovieThumbnailUploader
	mount_uploader :movie_screenshot_3, MovieThumbnailUploader
	mount_uploader :thumbnail_screenshot, MovieThumbnailUploader
	mount_uploader :thumbnail_640_screenshot, MovieThumbnailUploader
  mount_uploader :thumbnail_800_screenshot, MovieThumbnailUploader

  def thumb_screenshots_arr
    screen_shot_array = []
    [:movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3].each do |screen_shot|
      screen_shot_array << (CommonHelpers.cloud_front_url(self.send(screen_shot).path))
    end

    screen_shot_array
  end

  def screenshot_urls_map
    {
      original: image_url(movie_screenshot_1.carousel_thumb.path).to_s,
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
