#require 'aws-sdk'
class Provider::MoviesController < ApplicationController

  include Admin::MovieHandlers

  #before_action :authenticate_provider_user!
  before_action :set_provider_movie, only: [:show, :edit, :update, :destroy]

  layout 'provider'

  # GET /provider/movies
  def index
    @provider_movies = current_user.my_list_movies
  end

  # GET /provider/movies/1
  def show
    @movie_film_url = @provider_movie.film_video
  end

  # GET /provider/movies/new
  def new
    if params[:serial]
      @serail = params[:serial]
    end
    session[:movie_kind] = 'movie'
    @provider_movie = Movie.new
    @provider_movie.build_movie_thumbnail
  end

  # GET /provider/movies/1/edit
  def edit
    @s3_multipart = S3Multipart::Upload.find(@provider_movie.s3_multipart_upload_id)

    @movie_thumbnail = @provider_movie.movie_thumbnail || @provider_movie.build_movie_thumbnail
  end

  # PATCH/PUT /provider/movies/1
  def update
    if movie_params[:is_featured_film]
      previous_featured_film = Movie.find_by_is_featured_film(true)
    end

    if @provider_movie.update(movie_params)
      previous_featured_film.try(:set_is_featured_film_false)
      save_movie_thumbnails(@provider_movie)

      redirect_to provider_movie_path(@provider_movie), notice: I18n.t('flash.movie.successfully_updated')
    else
      render :edit
    end
  end

  # DELETE /provider/movies/1
  def destroy
    s3_multipart = S3Multipart::Upload.find(@provider_movie.s3_multipart_upload_id)
    if @provider_movie.has_trailer?
      movie_trailer = @provider_movie.movie_trailer
      s3_multipart_obj = S3Multipart::Upload.find(movie_trailer.s3_multipart_upload_id)
    end
    version_file = @provider_movie.version_file
    @provider_movie.destroy
    Movie.delete_movie_from_s3(s3_multipart, version_file)
    MovieTrailer.delete_file_from_s3(s3_multipart_obj) if s3_multipart_obj
    redirect_to provider_movies_url, notice: I18n.t('flash.movie.successfully_deleted')
  end

end
