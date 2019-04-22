#require 'aws-sdk'
class Admin::EpisodesController < ApplicationController

  include Admin::MovieHandlers

  before_action :authenticate_admin_user!
  before_action :set_admin_movie, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/episodes
  def index
    @admin_movies = Episode.joins(:season).where("seasons.admin_serial_id = :sid", sid: params[:serial_id].to_i)
  end

  # GET /admin/episodes/1
  def show
    @movie_film_url = @admin_movie.film_video
  end

  # GET /admin/episodes/new
  def new
    @serial = Serial.find_by(id: params[:serial_id])
    #@serial.seasons.create(season_number: 1) if @serial && @serial.seasons.empty?
    @admin_movie = Episode.new
    @admin_movie.season_id = params[:season_id]
    @admin_movie.build_movie_thumbnail
    session[:movie_kind] = 'episode'
    session[:current_season_id] = params[:season_id]
  end

  # GET /admin/episodes/1/edit
  def edit
    @s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
    @movie_thumbnail = @admin_movie.movie_thumbnail || @admin_movie.build_movie_thumbnail
  end

  # PATCH/PUT /admin/episodes/1
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

  # DELETE /admin/episodes/1
  def destroy
    serial = @admin_movie.season&.serial&.id
    s3_multipart = S3Multipart::Upload.find(@admin_movie.s3_multipart_upload_id)
    if @admin_movie.has_trailer?
      movie_trailer = @admin_movie.movie_trailer
      s3_multipart_obj = S3Multipart::Upload.find(movie_trailer.s3_multipart_upload_id)
    end
    version_file = @admin_movie.version_file
    @admin_movie.destroy
    Episode.delete_movie_from_s3(s3_multipart, version_file)
    MovieTrailer.delete_file_from_s3(s3_multipart_obj) if s3_multipart_obj
    flash[:notice] = I18n.t('flash.movie.successfully_deleted')
    redirect_to edit_admin_serial_url(serial)
  end
end
