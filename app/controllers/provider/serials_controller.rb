class Provider::SerialsController < ApplicationController
  before_action :authenticate_provider_user!
  before_action :set_provider_serial, only: [:show, :edit, :update, :destroy]

  include Admin::MovieHandlers
  include Wicked::Wizard

  layout 'provider'
  
  skip_before_action :setup_wizard, only: [:edit, :destroy]
  steps :add_details, :add_trailer, :add_episode, :add_screenshots, :add_thumbnails, :preview

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
      when 'rent_price' then 'rates.price'
      else 
        'admin_serials.created_at'
      end
    sort_order = "#{sort_col} #{direction}"
    @serials =
      if params[:search]
        current_user.own_serials.where("admin_serials.title like :search", search: "%#{params[:search]}%")
      else
        current_user.own_serials
      end
    @serials = @serials.joins(:genre, :rate).order(sort_order).limit(15)
    flash.now[:success] = "Found #{@serials.count} series"
  end

  def new
    @serial = Serial.new
    session[:flow] = 'create'
    redirect_to wizard_path(:add_details)
  end

  def edit
    session[:flow] = 'edit'
    @serial.build_serial_thumbnail unless @serial.serial_thumbnail
    @rate = @serial.rate || @serial.build_rate
    render :new
  end

  def choose_mode
    @serials = Serial.all
  end

  def select_season
    session[:kind] = 'episode'
    session[:current_season_id] = params[:season_id]
    render json: {result: 'success'}
  end


  def show
    case step
    when :add_details
      session[:movie_kind] = 'episode'
      @serial ||= Serial.new
      @serial.build_serial_thumbnail unless @serial.serial_thumbnail
      @rate = @serial.rate || @serial.build_rate
      render :new
      return
    when :add_trailer
    when :add_episode
      session[:kind] = 'episode'
      session[:current_season_id] = @serial.seasons&.first&.id
    when :add_screenshots
    when :add_thumbnails
    when :preview
    else
      @movie_film_url = @episode.film_video  # FIXME do we need this?
      render :show
      return
    end
    render_wizard + "?slug=#{@serial.slug}"
  end

  # PATCH/PUT /provider/serial/1
  def update
    @success = true
    case step
    when :add_details
      session[:movie_kind] = 'episode'
      params[:serial][:year] = params[:serial][:year].gsub("/", "-") if params.dig(:serial, :year)
      @success = @serial.update(fixed_serial_params)
      create_serial_service if @success
    when :add_trailer
    when :add_screenshots
      begin
        save_serial_thumbnails(@serial)
        flash[:success] ||= I18n.t('flash.serial.screenshots_added') 
      end
    when :add_thumbnails
      begin
        save_serial_thumbnails(@serial)
        flash[:success] ||= I18n.t('flash.serial.thumbnails_added') 
      end
    when :preview
    else
      Rails.logger.error "--- Uknown step: #{step} ----"
    end
    Rails.logger.debug "errors: #{@serial.errors}"
    if @success
      flash[:success] ||= I18n.t('flash.serial.successfully_updated') 
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

  def create
    begin
      @serial = current_user.own_serials.create(fixed_serial_params)
      @success = @serial.valid?
      if @success
        unless @serial.slug
          @serial.slug = fixed_serial_params[:title].gsub(/[\W]/,'-').downcase # FIXME!  why it was not autocreated ????
          @serial.save  #(validate: false)
        end
        create_serial_service
      end
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
            flash.now[:success] = I18n.t('flash.serial.successfully_created') 
          else
            flash.now[:error] = 'At least one error prevents Serial from being created'
          end
          render 'update'
          return
        }
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error e.message
      respond_to do |format|
        format.js {
          Rails.logger.error 'tp1.3'
          @success = false
          flash.now[:error] = e.message || 'At least one error prevents Serial from being created!'
          render 'update'
          return
        }
      end
    end
  end


  def destroy
    if @serial
      flash[:success] = I18n.t('flash.serial.successfully_deleted')
    else
      flash[:error] = 'Specified Serie not found'
    end
    @serial&.destroy
    redirect_to provider_serials_url
  end

  def fetch_seasons
    @seasons = @serial.seasons
    respond_to do |format|
      format.html { }
      format.js { render 'seasons' }
    end
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

  def fixed_serial_params
    sp = serial_params
    sp[:year]  = Date.parse("01/01/#{sp[:year]}")
    sp
  end

  def serial_params
    params.require(:serial).permit(
      :title, :year, :description, :admin_genre_id, :directed_by, :language, :star_cast, :seasons_number, 
      serial_thumbnail_attributes: [
        :id, :serial_screenshot_1, :serial_screenshot_2, :serial_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot
      ],
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
