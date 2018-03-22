class Api::V1::MovieSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :title, :description, :festival_laureates, :directed_by, :language, :released_date, :video_duration, :video_file, :genre_name, :click_count
  has_one :movie_thumbnail, serializer: Api::V1::MovieThumbnailSerializer
  has_many :user_video_last_stops
  has_many :movie_captions, serializer: Api::V1::MovieCaptionSerializer

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

  def movie_captions
    object.active_movie_captions if scope[:current_user]
  end

  def click_count
    bitly_clicks_result = BitlyClickCountService.new(object.bitly_url).call
    return bitly_response_parse_to_count_click(bitly_clicks_result) if bitly_clicks_result
  end

  private

  def bitly_response_parse_to_count_click (bitly_clicks_result)
    count_hash = {}
    Movie::SHARE_ON.each do |share_domain|
        count_hash["#{share_domain}"] = get_click_count(bitly_clicks_result, share_domain)
    end
    count_hash
  end

  def get_click_count(results, domain)
    result = results.select {|result| result["domain"].include?(domain)}.first
    result['clicks']
  end
end
