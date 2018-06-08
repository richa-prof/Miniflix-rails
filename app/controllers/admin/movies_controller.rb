require 'aws-sdk'
class Admin::MoviesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_admin_movie, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/movies
  def index
    @admin_movies = Movie.all
  end

  # GET /admin/movies/1
  def show
    @movie_film_url = @admin_movie.film_video
  end

  # GET /admin/movies/new
  def new
    @admin_movie = Movie.new
    @admin_movie.build_movie_thumbnail
  end

  def upload_movie_trailer
    @movie = Movie.find_by_s3_multipart_upload_id(params[:id])
  end

  def save_uploaded_movie_trailer
    success = false
    movie_id = params[:movie_id]
    upload_id = params[:upload_id]

    @movie = Movie.find_by_s3_multipart_upload_id(params[:movie_id])

    s3_upload = S3Multipart::Upload.find(upload_id)

    movie_trailer = MovieTrailer.new( admin_movie_id: movie_id,
                                      s3_multipart_upload_id: upload_id,
                                      uploader: s3_upload.uploader,
                                      file: s3_upload.location )

    if movie_trailer.save
      success = true
    end
    render json: { success: success }
  end

  def add_movie_details
    movie_trailer = MovieTrailer.find_by_s3_multipart_upload_id(params[:id])
    @admin_movie = movie_trailer.movie
    @s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
  end

  # GET /admin/movies/1/edit
  def edit
    @s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)

    @movie_thumbnail = @admin_movie.movie_thumbnail || @admin_movie.build_movie_thumbnail
  end

  # PATCH/PUT /admin/movies/1
  def update
    if movie_params[:is_featured_film]
      previous_featured_film = Movie.find_by_is_featured_film(true)
    end

    if @admin_movie.update(movie_params)
      previous_featured_film.try(:set_is_featured_film_false)
      save_movie_thumbnails(@admin_movie)

      redirect_to admin_movie_path(@admin_movie), notice: I18n.t('flash.movie.successfully_updated')
    else
      render :edit
    end
  end

  # DELETE /admin/movies/1
  def destroy
    s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
    version_file = @admin_movie.version_file
    @admin_movie.destroy
    Movie.delete_movie_from_s3(s3_multipart, version_file)

    redirect_to admin_movies_url, notice: I18n.t('flash.movie.successfully_deleted')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_movie
    @admin_movie = Movie.friendly.find(params[:id])
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
    params.require(:movie).permit(:name, :title, :description, :admin_genre_id, :film_video, :video_type, :video_size, :video_duration, :video_format, :directed_by, :language, :star_cast, :actors, :downloadable, :festival_laureates, :released_date, :posted_date, :is_featured_film)
  end
end
