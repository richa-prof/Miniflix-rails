class Api::V1::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :message, :movie_name, :created_at, :movie_thumbnail

  def movie_name
    object.movie_name
  end

  def created_at
    object.created_at.strftime('%A, %d %b %Y %l:%M %p')
  end

  def movie_thumbnail
   movie_thumbnail = object.movie.movie_thumbnail

   CommonHelpers.cloud_front_url(movie_thumbnail.thumbnail_screenshot.path)
  end
end
