#require 'aws-sdk'
class Provider::MoviesController < ApplicationController

  include Admin::MovieHandlers
  include Wicked::Wizard

  PER_PAGE = 15

  before_action :authenticate_provider_user!
  before_action :set_provider_movie, only: [:show, :edit, :update, :destroy]

  skip_before_action :setup_wizard, only: [:edit, :destroy]
  steps :add_details, :add_video, :add_screenshots, :add_thumbnails, :finalize, :preview #, only: [:show, :update]

  layout 'provider'

  # GET /provider/movies
  def index
    # direction switching happens in FE
    direction = params[:order] || 'desc'
    @dir = {
      year: 'desc',
      genre: 'desc',
      rate_price: 'desc'
    }
    @dir[params[:sort_by].to_sym] = direction if params[:sort_by]
    sort_col =
      case params[:sort_by]
      when 'year' then 'admin_movies.released_date'
      when 'genre' then 'admin_genres.name'
      when 'rent_price' then 'rates.price'
      else 
        'admin_movies.created_at'
      end
    sort_order = "#{sort_col} #{direction}"
    @provider_movies =
      if params[:search]
        current_user.own_movies.where("admin_movies.name like :search", search: "%#{params[:search]}%")
      else
        current_user.own_movies
      end
    @provider_movies = @provider_movies.joins(:genre, :rate).order(sort_order)
    count = @provider_movies.count
    @provider_movies = @provider_movies.limit(PER_PAGE)
    flash.now[:success] = "Found #{count} movies"
  end

  # GET /provider/movies/1
  def show
    @s3_multipart = S3Multipart::Upload.find(@provider_movie.s3_multipart_upload_id) if @provider_movie&.s3_multipart_upload_id 
    @movie_thumbnail = @provider_movie&.movie_thumbnail || @provider_movie&.build_movie_thumbnail
    case step
    when :add_details
      if params[:serial]
        @serial = Serial.find(params[:serial])
      end
      session[:movie_kind] = 'movie'
      @provider_movie ||= Movie.new
      @movie_thumbnail = @provider_movie.movie_thumbnail || @provider_movie.build_movie_thumbnail
      @provider_movie.build_movie_thumbnail unless @provider_movie.movie_thumbnail
      @rate = @provider_movie.rate || @provider_movie.build_rate
      render :new
      return
    when :add_video
      session[:current_video_id] = @provider_movie.id
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
    session[:flow] = 'create'
    redirect_to wizard_path(:add_details)
  end

  def create
    @provider_movie = current_user.own_movies.create!(fixed_movie_params)
    Rails.logger.debug @provider_movie.errors.messages
    @success = @provider_movie.valid?
    respond_to do |format|
      format.html {
        if @success
          redirect_to wizard_path(:add_video, slug: @provider_movie.slug), success: I18n.t('flash.movie.successfully_created')
        else 
          redirect_back(fallback_location: provider_movies_path)
        end
      }
      format.js {
        if @success
          flash[:success] = I18n.t('flash.movie.successfully_created') 
        else
          flash[:error] = 'At least one error prevents movie from being created'
        end
        render 'update'
      }
    end
  end

  # GET /provider/movies/1/edit
  def edit
    session[:flow] = 'edit'
    @s3_multipart = S3Multipart::Upload.find(@provider_movie.s3_multipart_upload_id) if @provider_movie&.s3_multipart_upload_id  # FIXME!
    @movie_thumbnail = @provider_movie.movie_thumbnail || @provider_movie.build_movie_thumbnail
    @provider_movie.build_movie_thumbnail unless @provider_movie.movie_thumbnail
    @rate = @provider_movie.rate || @provider_movie.build_rate
    render :new
  end

  # PATCH/PUT /provider/movies/1
  def update
    @success = true
    case step
    when :add_details
      session[:movie_kind] = 'movie'
      @success = @provider_movie.update!(fixed_movie_params)
    when :add_screenshots, :add_thumbnails
      begin
        thumb = save_movie_thumbnails(@provider_movie)
        if !thumb&.valid? && params[:movie_thumbnail].present?
          @success = false
          @provider_movie.errors.add(:base, thumb&.errors&.full_messages || 'Something went wrong!')
        end
      end
    when :finalize
    else
      Rails.logger.error "--- Uknown step: #{step} ----"
    end
    @s3_multipart = S3Multipart::Upload.find(@provider_movie.s3_multipart_upload_id) if @provider_movie&.s3_multipart_upload_id  # FIXME!
    #@movie_thumbnail = @provider_movie&.movie_thumbnail || @provider_movie.build_movie_thumbnail
    previous_featured_film = Movie.find_by_is_featured_film(true) if movie_params[:is_featured_film]
    Rails.logger.debug "errors: #{@provider_movie.errors}"
    if @success
      flash[:success] = I18n.t('flash.movie.successfully_updated') 
    else
      flash[:error] = @provider_movie.errors.full_messages
    end
    respond_to do |format|
      format.html {
        if @success
          previous_featured_film.try(:set_is_featured_film_false)
          redirect_to wizard_path(next_step, slug: @provider_movie.slug)
        else 
          Rails.logger.error flash[:error]
          redirect_back(fallback_location: provider_movies_path)
        end
      }
      format.js {
        render 'update'
      }
    end
  end

  # DELETE /provider/movies/1
  def destroy
    s3_multipart = S3Multipart::Upload.find_by(id: @provider_movie&.s3_multipart_upload_id)
    if @provider_movie.has_trailer?
      movie_trailer = @provider_movie.movie_trailer
      s3_multipart_obj = S3Multipart::Upload.find_by(id: movie_trailer.s3_multipart_upload_id)
    end
    version_file = @provider_movie.version_file
    @provider_movie.destroy
    Movie.delete_movie_from_s3(s3_multipart, version_file) if s3_multipart
    MovieTrailer.delete_file_from_s3(s3_multipart_obj) if s3_multipart_obj
    redirect_to provider_movies_url, success: I18n.t('flash.movie.successfully_deleted')
  end

  private

  def fixed_movie_params
    mp = movie_params
    mp[:released_date]  = Date.parse("#{mp[:released_date]}/01/01")
    mp
  end

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
      ],
      rate_attributes: [
        :price, :notes, :discount, :id, :entity_id, :entity_type
      ]
    )
  end


end
