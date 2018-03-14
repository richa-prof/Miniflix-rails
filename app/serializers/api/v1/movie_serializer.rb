class Api::V1::MovieSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :description, :festival_laureates, :directed_by, :language, :released_date, :video_duration, :video_file, :genre_name
  has_one :movie_thumbnail
  has_many :user_video_last_stops

  def video_file
    if (scope[:current_user] && scope[:current_user].is_payment_verified?)
      object.hls_movie_url
    end
  end

  def genre_name
    object.genre_name
  end

  def user_video_last_stops
    if scope[:current_user]
      user_video_last_stop = scope[:current_user].user_video_last_stops.find_by(admin_movie_id: object.id)
      ActiveModelSerializers::SerializableResource.new(user_video_last_stop,
          serializer: Api::V1::UserVideoLastStopSerializer).serializable_hash if user_video_last_stop.present?
    end
  end
end
