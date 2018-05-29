module Admin::MoviesHelper

  def supported_video_formats_map
    Movie::SUPPORTED_FORMATS.map { |v| [v, v] }
  end

  def featured_film_value_for(movie)
    movie.is_featured_film ? 'Yes' : 'No'
  end

  def featured_film_content_css_class(movie)
    movie.is_featured_film ? 'text-success' : 'text-danger'
  end

  def render_thumbnail_image_for(is_edit_mode, thumbnail_type, thumbnail_screenshot)
    target_image_url = if is_edit_mode && thumbnail_screenshot.present?
                        thumbnail_screenshot.url
                      else
                        get_default_thumbnail_url_for(thumbnail_type)
                      end

    image_tag(target_image_url).html_safe
  end

  def get_default_thumbnail_url_for(thumbnail_type)
    case thumbnail_type
    when 'thumbnail_640_screenshot'
      'admin/upload_img640.png'
    when 'thumbnail_screenshot'
      'admin/upload_img330.png'
    when 'thumbnail_800_screenshot'
      'admin/upload_img800.png'
    else
      'admin/upload_img.png'
    end
  end

  def movie_posted_on_details_for(movie)
    posted_date = movie.posted_date

    if posted_date.present?
      t( 'content.movie.posted_on_details', formatted_date: posted_date.to_s(:movie_posted_on_format) )
    else
      content_tag( :i, '(Not Available)' )
    end
  end

  def formatted_released_date_for(movie)
    released_date = movie.released_date

    return t('label.not_available') unless released_date.present?

    released_date.to_s(:full_date_month_and_year_format)
  end
end
