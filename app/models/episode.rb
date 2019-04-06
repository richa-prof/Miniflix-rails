class Episode < Movie

  # ASSOCIATIONS

  belongs_to :season


  # CALLBACKS
  #before_save :create_bitly_url, if: -> { slug_changed? }
  #after_create :write_file
  #after_update :send_notification

  def next
    season.episodes.where('created_at > ?', created_at)
  end

  def compact_response
    {
      episode_id: id, 
      title: title.to_s, 
      season_number: season&.season_number&.to_i,
      description: description.to_s,
      date_of_release: created_at&.utc&.iso8601,
      video_duration: video_duration.to_s,
      last_stopped: UserVideoLastStop.where("admin_movie_id = ?", id).count  # FIXME!
    }
  end

  def film_video_map
    h = {
      hls: film_video,
      video_720: "",
      video_480: "",
      video_320: ""
    }
    movie_versions.each do |mv|
      h["video_#{mv.resolution}".to_sym] = mv.film_video.to_s
    end
    h.merge!(fetch_movie_urls)
  end

  def screenshot_list
    movie_thumbnail.screenshot_urls_map
  end

  def format(mode: nil)
    case mode
    when "compact"
      compact_response
    else
      compact_response.merge!(
       film_video: film_video_map,
       screenshot: screenshot_list
      )
    end
  end

end


