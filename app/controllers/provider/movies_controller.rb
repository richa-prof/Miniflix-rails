#require 'aws-sdk'
class Provider::MoviesController < ApplicationController

  include Admin::MovieHandlers
  include Wicked::Wizard

  #before_action :authenticate_provider_user!
  before_action :set_provider_movie, only: [:show, :edit, :update, :destroy]

  steps :add_details, :add_video, :add_screenshots, :add_thumbnails, :finalize

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
    p @provider_movie.inspect
    
    case step
    when :add_details
    when :add_video
      # " /provider/movies/upload_movie_trailer/" 
    when :add_screenshots
    when :add_thumbnails
    when :finalize
    else
      @movie_film_url = @provider_movie.film_video  
      render :show
      return
    end
    render_wizard + "?slug=#{@provider_movie.slug}"
  end

  # GET /provider/movies/new
  def new
    if params[:serial]
      @serial = params[:serial]
    end
    session[:movie_kind] = 'movie'
    @movie = Movie.new
    @movie.build_movie_thumbnail
    @rate = @movie.build_rate
    #render wizard_path(:add_details)
  end

  def create
    @provider_movie = Movie.create!(movie_params)
    @provider_movie.save(validate: false)
    #redirect_to edit_provider_movie_path(@provider_movie), notice: I18n.t('flash.movie.successfully_created')
    redirect_to wizard_path(:add_video, slug: @provider_movie.slug), notice: I18n.t('flash.movie.successfully_created')
  end

  def after_create
  
  end

  # GET /provider/movies/1/edit
  def edit
    @s3_multipart = S3Multipart::Upload.find(@provider_movie.s3_multipart_upload_id) if @provider_movie&.s3_multipart_upload_id  # FIXME!
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
      Movie.find_by(slug: params[:slug] || params[:id])
  end

  def movie_params
    params.require(:movie).permit(
      :title, :name, :film_video, :video_type, :video_size, :video_format, :video_duration,
      :released_date, :description, :admin_genre_id, :directed_by, :language, :star_cast, 
      :kind, :slug, :bitly_url, :version_file, :downloadable, :actors,
      movie_thumbnail_attributes: [
        :id, :movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot
      ]
    )
  end


end
