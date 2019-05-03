#require 'aws-sdk'
class Provider::EpisodesController < ApplicationController

  include Admin::MovieHandlers
  include Wicked::Wizard

  PER_PAGE = 15

  before_action :authenticate_provider_user!
  before_action :set_episode, only: [:show, :edit, :update, :destroy]
  before_action :set_serial, only: [:new, :show, :edit]

  skip_before_action :setup_wizard, only: [:edit, :destroy]
  steps :add_details, :add_video, :add_screenshots, :add_thumbnails, :finalize, :preview #, only: [:show, :update]

  layout 'provider'

  # GET /provider/episodes/1
  def show
    @s3_multipart = S3Multipart::Upload.find(@episode.s3_multipart_upload_id) if @episode&.s3_multipart_upload_id 
    @movie_thumbnail = @episode&.movie_thumbnail || @episode&.build_movie_thumbnail
    case step
    when :add_details
      # if params[:serial]
      #   @serial = Serial.find(params[:serial])
      # end
    respond_to do |format|
      format.js { 
        @seasons = @serial.seasons if params[:serial]
        render 'seasons'
        return
      }
      format.html {
        Rails.logger.debug "creating new Episode"
        session[:movie_kind] = 'episode'
        @episode = Episode.new
        @episode.build_movie_thumbnail
        @rate = @episode.build_rate
        render :new
        return
      }
    end
    when :add_video
      session[:current_video_id] = @episode.id
    when :add_screenshots
    when :add_thumbnails
    when :finalize
    else
      @movie_film_url = @episode.film_video
      render :show
      return
    end
    render_wizard + "?slug=#{@episode.slug}"
  end

  # GET /provider/episodes/new
  def new
    session[:flow] = 'create'
    redirect_to wizard_path(:add_details, serial: params[:serial])
  end

  def create
    begin
      @episode = Episode.create(fixed_episode_params)
      @success = @episode.valid?
      respond_to do |format|
        format.html {
          if @success
            redirect_to wizard_path(:add_video, slug: @episode.slug), success: I18n.t('flash.episode.successfully_created')
          else 
            redirect_back(fallback_location: provider_series_path)
          end
        }
        format.js {
          if @success
            flash[:success] = I18n.t('flash.episode.successfully_created') 
          else
            flash[:error] = 'At least one error prevents Episode from being created'
          end
          render 'update'
        }
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug e.message
      respond_to do |format|
        format.js {
          @success = false
          flash[:error] = 'At least one error prevents Episode from being created'
          render 'update'
          return
        }
      end
    end
  end

  # GET /provider/episodes/1/edit
  def edit
    session[:flow] = 'edit'
    @s3_multipart = S3Multipart::Upload.find(@episode.s3_multipart_upload_id) if @episode&.s3_multipart_upload_id  # FIXME!
    @movie_thumbnail = @episode.movie_thumbnail || @episode.build_movie_thumbnail
    @episode.build_movie_thumbnail unless @episode.movie_thumbnail
    @rate = @episode.rate || @episode.build_rate
    render :new
  end

  # PATCH/PUT /provider/episodes/1
  def update
    @success = true
    case step
    when :add_details
      session[:movie_kind] = 'episode'
      @success = @episode.update!(fixed_episode_params)
    when :add_screenshots, :add_thumbnails
      begin
        thumb = save_movie_thumbnails(@episode)
        if !thumb&.valid? && params[:movie_thumbnail].present?
          @success = false
          @episode.errors.add(:base, thumb&.errors&.full_messages || 'Something went wrong!')
        end
      end
    when :finalize
    else
      Rails.logger.error "--- Uknown step: #{step} ----"
    end
    @s3_multipart = S3Multipart::Upload.find(@episode.s3_multipart_upload_id) if @episode&.s3_multipart_upload_id  # FIXME!
    #@movie_thumbnail = @episode&.movie_thumbnail || @episode.build_movie_thumbnail
    previous_featured_film = Episode.find_by_is_featured_film(true) if episode_params[:is_featured_film]
    Rails.logger.debug "errors: #{@episode.errors}"
    if @success
      flash[:success] = I18n.t('flash.episode.successfully_updated') 
    else
      flash[:error] = @episode.errors.full_messages
    end
    respond_to do |format|
      format.html {
        if @success
          previous_featured_film.try(:set_is_featured_film_false)
          redirect_to wizard_path(next_step, slug: @episode.slug)
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

  # DELETE /provider/episodes/1
  def destroy
    s3_multipart = S3Multipart::Upload.find_by(id: @episode&.s3_multipart_upload_id)
    if @episode.has_trailer?
      movie_trailer = @episode.movie_trailer
      s3_multipart_obj = S3Multipart::Upload.find_by(id: movie_trailer.s3_multipart_upload_id)
    end
    version_file = @episode.version_file
    @episode.destroy
    Episode.delete_movie_from_s3(s3_multipart, version_file) if s3_multipart
    MovieTrailer.delete_file_from_s3(s3_multipart_obj) if s3_multipart_obj
    redirect_to provider_movies_url, success: I18n.t('flash.episode.successfully_deleted')
  end


  private

  def fixed_episode_params
    mp = episode_params
    mp[:released_date]  = Date.parse("#{mp[:released_date]}/01/01")
    mp[:name] = mp[:title].parameterize
    mp
  end

  def set_episode
    @episode ||= Episode.friendly.find_by(id: params[:id]) || Episode.find_by_s3_multipart_upload_id(params[:id])
    @episode ||= Episode.find_by(slug: params[:slug])  if params[:slug]
      
  end

  def set_serial
    s = params[:serial]
    @serial = @episode&.persisted? ? @episode.serial :  Serial.find_by(id: s) || Serial.friendly.find_by(id: s) || Serial.find_by(slug: s) || current_user.own_serials.first
    Rails.logger.debug "serial: #{@serial.inspect}"
    @serial
  end

  def episode_params
    params.require(:episode).permit(
      :title, :name, :film_video, :video_type, :video_size, :video_format, :video_duration, :season_id,
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
