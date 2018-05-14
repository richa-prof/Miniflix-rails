module Admin::MovieCaptionsHelper

  def language_list_for(movie, movie_caption)
    language_used = movie.movie_captions.pluck(:language)
    all_language = MovieCaption::LANGUAGE
    language = all_language - language_used
    language << movie_caption.language if movie_caption.language.present?
    language
  end

  def check_for_default_caption(movie)
    (movie.movie_captions.default_caption.present?) ? "default_caption" : ""
  end

  def formatted_caption_filename(movie_caption)
    filename = movie_caption.caption_file.try(:filename)

    return filename if filename.blank?

    filename.split('/').last
  end
end
