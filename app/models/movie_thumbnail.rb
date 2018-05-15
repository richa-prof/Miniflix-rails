class MovieThumbnail < ApplicationRecord
  self.table_name = "admin_movie_thumbnails"
  belongs_to :movie, :foreign_key => 'admin_movie_id'

  mount_uploader :movie_screenshot_1, MovieThumbnailUploader
	mount_uploader :movie_screenshot_2, MovieThumbnailUploader
	mount_uploader :movie_screenshot_3, MovieThumbnailUploader
	mount_uploader :thumbnail_screenshot, MovieThumbnailUploader
	mount_uploader :thumbnail_640_screenshot, MovieThumbnailUploader

  def cloud_front_url(path)
    # ENV['cloud_front_url'] + path
    'https://' +  ENV['cloud_front_url'] +'/'+ path
  end
end
