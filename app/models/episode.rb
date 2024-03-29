class Episode < Movie

  belongs_to :season

  def next
    season.episodes.where('created_at > ?', created_at)
  end

  def serial
    season&.serial
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
      hls: film_video.to_s,
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
    out = {
      original: "",
      thumb330: "",
      thumb640: "",
      thumb800: ""
    }
    if movie_thumbnail
      out.merge! movie_thumbnail&.screenshot_urls_map
    else
      Rails.logger.error "No thumbnail exist for Episode #{id} !!"
    end
    out
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


