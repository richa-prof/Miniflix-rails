module Admin::MovieCaptionsHelper

  def language_list
    language_used = @admin_movie.movie_captions.pluck(:language)
    all_language = Admin::MovieCaption::LANGUAGE
    language = all_language - language_used
    language << @movie_caption.language if @movie_caption.language.present?
    language
  end

  def check_for_default_caption
    (@admin_movie.movie_captions.default_caption.present?) ? "default_caption" : ""
  end
end
