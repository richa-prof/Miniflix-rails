class Api::V1::MovieSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :description, :festival_laureates, :directed_by, :language, :released_date, :video_duration, :video_file, :genre_name
  has_one :movie_thumbnail

  def video_file
    if (scope[:current_user] && scope[:current_user].is_payment_verified?)
      object.hls_movie_url
    end
  end

  def genre_name
    object.genre_name
  end
end
