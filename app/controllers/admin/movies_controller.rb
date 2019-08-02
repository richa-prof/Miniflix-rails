#require 'aws-sdk'
class Admin::MoviesController < ApplicationController

  include Admin::MovieHandlers

  before_action :authenticate_admin_user!
  before_action :set_admin_movie, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/movies
  def index
    @admin_movies = Movie.where("s3_multipart_upload_id IS NOT NULL").distinct
  end

  # GET /admin/movies/1
  def show
    @movie_film_url = @admin_movie.film_video
  end

  # GET /admin/movies/new
  def new
    if params[:serial]
      @serail = params[:serial]
    end
    session[:movie_kind] = 'movie'
    @admin_movie = Movie.new
    @admin_movie.build_movie_thumbnail
  end

  # GET /admin/movies/1/edit
  def edit
    @s3_multipart = S3Multipart::Upload.find_by(id: @admin_movie.s3_multipart_upload_id)

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
    s3_multipart = S3Multipart::Upload.find_by(id: @admin_movie.s3_multipart_upload_id)
    Rails.logger.error "Movie #{@admin_movie.inspect} don't have s3_multipart_upload_id!"
    if @admin_movie.has_trailer? && s3_multipart
      movie_trailer = @admin_movie.movie_trailer
      s3_multipart_obj = S3Multipart::Upload.find_by(id: movie_trailer.s3_multipart_upload_id)
    end
    version_file = @admin_movie.version_file
    @admin_movie.destroy
    Movie.delete_movie_from_s3(s3_multipart, version_file) if s3_multipart
    MovieTrailer.delete_file_from_s3(s3_multipart_obj) if s3_multipart_obj
    redirect_to admin_movies_url, notice: I18n.t('flash.movie.successfully_deleted')
  end

end
