class Api::V1::MovieSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :title, :description, :festival_laureates, :directed_by, :language,
             :released_date, :video_duration, :video_file, :trailer_file, :genre_name, :click_count, :is_liked, :is_featured_film, :social_urls, :movie_file_url

  has_one :genre, serializer: Api::V1::GenreSerializer
  has_one :movie_thumbnail, serializer: Api::V1::MovieThumbnailSerializer
  has_many :user_video_last_stops, serializer: Api::V1::UserVideoLastStopSerializer
  has_many :movie_captions, serializer: Api::V1::MovieCaptionSerializer

  def battleship
    false
  end

  def video_file
    object.hls_movie_url if valid_user?
  end

  def genre_name
    object.genre_name
  end

  def user_video_last_stops
    scope[:current_user].user_video_last_stops.find_by(admin_movie_id: object.id) if scope[:current_user]
  end

  def movie_captions
    object.active_movie_captions if scope[:current_user]
  end

  def movie_file_url
    object.film_video.gsub('http://', 'https://') if object.film_video.present?
  end

  def click_count
    bitly_clicks_result = BitlyClickCountService.new(object.bitly_url).call
    return bitly_response_parse_to_count_click(bitly_clicks_result) if bitly_clicks_result.present?
  end

  def is_liked
    scope[:current_user].my_list_movie_ids.include?(object.id) if scope[:current_user]
  end

  def trailer_file
    object.movie_trailer.try(:file_cloudfront_url)
  end

  def social_urls
    urls_map = { }
    Movie::SHARE_ON.each do |share_domain|
      url = get_social_share_url(object, share_domain)
      urls_map.merge!({share_domain => url})
    end

    urls_map
  end

  private

  def valid_user?
    (scope[:current_user] && scope[:current_user].is_payment_verified?)
  end

  def bitly_response_parse_to_count_click (bitly_clicks_result)
    count_hash = {}
    Movie::SHARE_ON.each do |share_domain|
        count_hash["#{share_domain}"] = get_click_count(bitly_clicks_result, share_domain)
    end
    count_hash
  end

  def get_click_count(results, domain)
    result = results.select {|result| result["domain"].include?(domain)}.first
    result['clicks'] if result.present?
  end

  def get_social_share_url(obj, share_on)
    title = object.name
    description = object.description.truncate(150) rescue ''
    # target_url = object.bitly_url
    target_url = "#{ENV['Host']}/movies/#{object.slug}"

    url = case share_on
          when 'facebook'
            "http://www.facebook.com/sharer/sharer.php?u=#{target_url}"
          when 'twitter'
            "https://twitter.com/intent/tweet?url=#{target_url}&text=#{title}"
          end

    url
  end
end
