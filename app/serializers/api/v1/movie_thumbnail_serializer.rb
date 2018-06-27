class Api::V1::MovieThumbnailSerializer < ActiveModel::Serializer

  # attributes :movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3
  attributes :main_screenshot, :other_screenshots


  def main_screenshot
    target_path = object.movie_screenshot_1.carousel_thumb.try(:path)

    CommonHelpers.cloud_front_url(target_path)
  end

  def other_screenshots
    screen_shot_array = []
    [:movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3].each do |screen_shot|
      screen_shot_array << (CommonHelpers.cloud_front_url(object.send(screen_shot).featured_thumb.path))
    end
    screen_shot_array
  end

end
