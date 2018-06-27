module MoviesHelper

  def main_screenshot_url(movie)
    movie_thumbnail = movie.movie_thumbnail
    carousel_thumb = movie_thumbnail.movie_screenshot_1.carousel_thumb.path

    CommonHelpers.cloud_front_url(carousel_thumb)
  end

  def movies_og_shareable_url(movie)
    # movie_url(movie)
    "#{ENV['RAILS_HOST']}/movies/#{movie.slug}"
  end
end
