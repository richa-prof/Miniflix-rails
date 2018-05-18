class Api::V1::MovieThumbnailSerializer < ActiveModel::Serializer

  # attributes :movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3
  attributes :main_screenshot, :other_screenshots


  def main_screenshot
    object.cloud_front_url(object.movie_screenshot_1.genre_wise_thumb.path)
  end

  def other_screenshots
    screen_shot_array = []
    [:movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3].each do |screen_shot|
      screen_shot_array << (object.cloud_front_url(object.send(screen_shot).featured_thumb.path))
    end
    screen_shot_array
  end

end
