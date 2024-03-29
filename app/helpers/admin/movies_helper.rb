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
    target_image_url =
      if is_edit_mode && thumbnail_screenshot.present?
        CommonHelpers.cloud_front_url(thumbnail_screenshot.path)
      else
        get_default_thumbnail_url_for(thumbnail_type)
      end
    image_tag(target_image_url).html_safe
  end

  def get_default_thumbnail_url_for(thumbnail_type)
    case thumbnail_type
    when 'thumbnail_640_screenshot'
      'admin/upload_img640.jpg'
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

  def formatted_released_date_for_movie(movie)
    released_date = movie.released_date
    return t('label.not_available') unless released_date.present?
    released_date.to_s(:full_date_month_and_year_format)
  end

  def get_url_for_next_page(params)
    case params['id'].to_sym
    when :add_details
      provider_movie_path(:add_video, slug: @provider_movie.slug)
    when :add_video
      provider_movie_path(:add_screenshots, slug: @provider_movie.slug)
    when :add_screenshots
      provider_movie_path(:add_thumbnails, slug: @provider_movie.slug)
    when :add_thumbnails
      provider_movie_path(:preview, slug: @provider_movie.slug)
    when :edit
      provider_movie_path(:add_video, slug: @provider_movie.slug)
    end
  end

  def get_url_for_previous_page(params)
    case params['id'].to_sym
    when :add_video
      edit_provider_movie_path(@provider_movie)
    when :add_screenshots
      provider_movie_path(:add_video, slug: @provider_movie.slug)
    when :add_thumbnails
      provider_movie_path(:add_screenshots, slug: @provider_movie.slug)
    when :preview
      provider_movie_path(:add_thumbnails, slug: @provider_movie.slug)
    end
  end
end
