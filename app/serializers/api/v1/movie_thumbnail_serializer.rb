class Api::V1::MovieThumbnailSerializer < ActiveModel::Serializer

  # attributes :movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3

  [:movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3].each do |screen_shot|
    attributes screen_shot
    define_method(screen_shot) do
      image_url (object.send(screen_shot).featured_thumb.path)
    end
  end

  private
  def image_url(path)
    ENV['cloud_front_url'] + path
  end
end
