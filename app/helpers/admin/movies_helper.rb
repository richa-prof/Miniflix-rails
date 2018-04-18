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
end
