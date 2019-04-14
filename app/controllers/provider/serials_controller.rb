class Provider::SerialsController < ApplicationController
  #before_action :authenticate_provider_user!
  before_action :set_provider_serial, only: [:show, :edit, :update, :destroy]

  include Wicked::Wizard

  layout 'provider'
  steps :add_details, :add_trailer, :add_episode, :add_screenshots, :add_thumbnails, :finalize, :preview

  def index
    # direction switching happens in BE
    direction = params[:order] || 'desc'
    @dir = {
      year: 'desc',
      genre: 'desc',
      rate_price: 'desc'
    }
    @dir[params[:sort_by].to_sym] = direction if params[:sort_by]
    sort_col =
      case params[:sort_by]
      when 'year' then 'admin_serials.updated_at'
      when 'genre' then 'admin_genres.name'
      when 'rate_price' then ''
      else 
        'admin_serials.created_at'
      end
    sort_order = "#{sort_col} #{direction}"
    @serials =
      if params[:search]
        Serial.where("admin_serials.name like :search", search: "%#{params[:search]}%").joins(:genre).order(sort_order)
      else
        Serial.joins(:genre).order(sort_order).limit(15)  #current_user.my_list_movies
      end
      flash[:success] = "Found #{@serials.count} series"
  end

  def new
    @serial = Serial.new
    session[:flow] = 'create'
    redirect_to wizard_path(:add_details)
  end

  def choose_mode
    @serials = Serial.all
  end

  def show
    #@s3_multipart = S3Multipart::Upload.find(@episode.s3_multipart_upload_id) if @episode&.s3_multipart_upload_id 
    #@movie_thumbnail = @episode&.movie_thumbnail || @episode&.build_movie_thumbnail
    case step
    when :add_details
      session[:movie_kind] = 'episode'
      @serial = Serial.new
      @serial.build_serial_thumbnail
      @rate = @serial.build_rate
      render :new
      return
    when :add_trailer
    when :add_episode
      # " /provider/movies/upload_movie_trailer/" 
    when :add_screenshots
    when :add_thumbnails
    when :finalize
    else
      @movie_film_url = @episode.film_video  
      render :show
      return
    end
    render_wizard + "?slug=#{@serial.slug}"
  end

  # PATCH/PUT /provider/serial/1
  def update
    case step
    when :add_details
      session[:movie_kind] = 'episode'
    when :add_trailer
    when :finalize
    else
      Rails.logger.error "--- Uknown step: #{step} ----"
    end
    @success = @serial.update(serial_params)
    #@s3_multipart = S3Multipart::Upload.find(@serial.s3_multipart_upload_id) if @serial&.s3_multipart_upload_id  # FIXME!
    #@movie_thumbnail = @serial&.movie_thumbnail || @serial.build_movie_thumbnail
    Rails.logger.debug "errors: #{@serial.errors}"
    if @success
      flash[:success] = I18n.t('flash.serial.successfully_updated') 
    else
      flash[:error] = 'At least one error prevents Serie from being updated'
    end
    respond_to do |format|
      format.html {
        if @serial.valid?
          previous_featured_film.try(:set_is_featured_film_false)
          redirect_to wizard_path(next_step, slug: @serial.slug)
          #redirect_to next_wizard_path(slug: @serial.slug), notice: I18n.t('flash.movie.successfully_updated')
        else 
          Rails.logger.error @serial.errors.full_messages
          redirect_back(fallback_location: provider_movies_path)
        end
      }
      format.js {
        render 'update'
      }
    end
  end

  def create
    @serial = Serial.create!(serial_params)
    slug = serial_params[:title].gsub(/[\W]/,'-').downcase # FIXME!  why it was not autocreated ????
    @serial.slug ||= slug
    @serial.save  #(validate: false)
    Rails.logger.debug @serial.errors.messages
    @success = @serial.valid?
    create_serial_service if @success
    respond_to do |format|
      format.html {
        if @success
          redirect_to wizard_path(:add_trailer, slug: @serial.slug), success: I18n.t('flash.serial.successfully_created')
        else 
          redirect_back(fallback_location: provider_serials_path)
        end
      }
      format.js {
        if @success
          flash[:success] = I18n.t('flash.serial.successfully_created') 
        else
          flash[:error] = 'At least one error prevents Serial from being created'
        end
        render 'update'
      }
    end
  end

  def update
    params[:serial][:year] = params[:serial][:year].gsub("/", "-")
    @success = @serial.update(serial_params)
    create_serial_service if @success
    case step
    when :add_details
      session[:movie_kind] = 'episode'
    when :add_screenshots 
      begin
         save_serial_thumbnails(@serial) if @success
      end
    when :add_thumbnails 
    when :finalize
    else
      Rails.logger.error "--- Uknown step: #{step} ----"
    end
    Rails.logger.debug "errors: #{@serial.errors}"
    if @success
      flash[:success] = I18n.t('flash.serial.successfully_updated') 
    else
      flash[:error] = 'At least one error prevents Serial from being updated'
    end
    respond_to do |format|
      format.html {
        if @success
          redirect_to wizard_path(next_step, slug: @serial.slug)
        else 
          redirect_back(fallback_location: provider_serials_path)
        end
      }
      format.js {
        render 'update'
      }
    end
  end

  def destroy
    @serial.destroy
    redirect_to provider_serials_url, notice: I18n.t('flash.serial.successfully_deleted')
  end

  private

  def create_serial_service
    SerialService.new(
      author: current_user,
      params: params,
      serial: @serial
    ).call
  end

  def set_provider_serial
    @serial ||= Serial.friendly.find_by(id: params[:id]) || Serial.find_by(slug: params[:slug] || params[:id])
  end

  def serial_params
    params.require(:serial).permit(
      :title, :year, :description, :admin_genre_id, :directed_by, :language, :star_cast, :seasons_number, 
      serial_thumbnail_attributes: [:id, :serial_screenshot_1, :serial_screenshot_2, :serial_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot],
      rate_attributes: [
        :price, :notes, :discount, :id, :entity_id, :entity_type
      ]
    )
  end

  def save_serial_thumbnails(provider_serial)
    serial_thumbnail = provider_serial.serial_thumbnail

    return unless params[:serial_thumbnail].present?

    if serial_thumbnail.present?
      serial_thumbnail.update(serial_thumbnail_params)
    else
      serial_thumbnail = provider_serial.build_serial_thumbnail(serial_thumbnail_params)
      serial_thumbnail.save
    end
  end

  def serial_thumbnail_params
    params.require(:serial_thumbnail).permit(:serial_screenshot_1, :serial_screenshot_2, :serial_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot)
  end

end
