#require 'aws-sdk'
class Provider::MoviesController < ApplicationController

  include Admin::MovieHandlers

  #before_action :authenticate_provider_user!
  before_action :set_provider_movie, only: [:show, :edit, :update, :destroy]

  layout 'provider'

  # GET /provider/movies
  def index
    # direction switching happens in BE
    direction = params[:order] || 'desc'
    @dir = {
      year: 'desc',
      genre: 'desc',
      rate_price: 'desc'
    }
    @dir[params[:sort_by].to_sym] = direction if params[:sort_by]
    Rails.logger.debug @dir
    sort_col =
      case params[:sort_by]
      when 'year' then 'admin_movies.released_date'
      when 'genre' then 'admin_genres.name'
      when 'rate_price' then ''
      else 
        'admin_movies.created_at'
      end
    sort_order = "#{sort_col} #{direction}"
    @provider_movies =
      if params[:search]
        Movie.where("admin_movies.name like :search", search: "%#{params[:search]}%").joins(:genre).order(sort_order)
      else
        Movie.joins(:genre).order(sort_order).limit(15)  #current_user.my_list_movies
      end
      flash[:success] = "Found #{@provider_movies.count} movies"
    #redirect_to action: :new
  end

  # GET /provider/movies/1
  def show
    @movie_film_url = @provider_movie.film_video
  end

  # GET /provider/movies/new
  def new
    if params[:serial]
      @serial = params[:serial]
    end
    session[:movie_kind] = 'movie'
    @movie = Movie.new
    @movie.build_movie_thumbnail
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

  private

  def set_provider_movie
    @provider_movie ||= Movie.friendly.find_by(id: params[:id]) ||
      Movie.find_by_s3_multipart_upload_id(params[:id]) ||
      Movie.find_by(name: params[:id].to_s.upcase.gsub('-','.'))
  end

end
