require 'aws-sdk'

module Admin::MovieHandlers

  # !important to pass with request !!
  def kind
     params[:kind]
  end

  def movie_id_param
     @movie_id_param ||= params["#{kind}_id".to_sym]
  end

  def klass
    kind.humanize.constatize
  end

  def upload_movie_trailer
    kind.constantize.class.find_by_s3_multipart_upload_id(params[:id])
  end

  def save_uploaded_movie_trailer
    success = false
    upload_id = params[:upload_id]
    @movie = klass.find(movie_id_param)
    s3_upload = S3Multipart::Upload.find(upload_id)
    movie_trailer = @movie.create_movie_trailer(
      s3_multipart_upload_id: upload_id,
      uploader: s3_upload.uploader,
      admin_serial_id: @movie.season&.serial&.id,
      file: s3_upload.location
    )
    if movie_trailer.valid?
      success = true
    end
    render json: { success: success }
  end

  def add_movie_details
    movie_trailer = MovieTrailer.find_by_s3_multipart_upload_id(params[:id])
    @admin_movie = movie_trailer.movie
    @s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_movie
    @admin_movie = Movie.friendly.find(params[:id])
    # @admin_movie = kind.constantize.friendly.find(params[:id])

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def movie_params
    modified_params = movie_default_params
    posted_date_param = modified_params.delete(:posted_date)
    released_date_param = modified_params.delete(:released_date)
    posted_date = Date.strptime(posted_date_param, '%m/%d/%Y').to_date rescue nil
    released_date = Date.strptime(released_date_param, '%m/%d/%Y').to_date rescue nil
    modified_params[:released_date] = released_date if released_date.present?
    modified_params[:posted_date] = posted_date if posted_date.present?
    modified_params
  end

  def movie_thumbnail_params
    params.require(:movie_thumbnail).permit(:movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot)
  end

  def save_movie_thumbnails(movie)
    movie_thumbnail = movie.movie_thumbnail
    return unless params[:movie_thumbnail].present?
    if movie_thumbnail.present?
      movie_thumbnail.update(movie_thumbnail_params)
    else
      movie_thumbnail = movie.build_movie_thumbnail(movie_thumbnail_params)
      movie_thumbnail.save
    end
  end

  def movie_default_params
    params.require(kind.to_sym).permit(
      :name, :title, :description, :admin_genre_id, :admin_serial_id, :film_video, :video_type, :video_size, :video_duration, :video_format,
      :directed_by, :language, :star_cast, :actors, :downloadable, :festival_laureates, :released_date, :posted_date, :is_featured_film
    )
  end

end
