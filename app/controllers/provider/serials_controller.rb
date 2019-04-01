class Provider::SerialsController < ApplicationController
  #before_action :authenticate_provider_user!
  before_action :set_provider_serial, only: [:show, :edit,:update, :destroy]

  layout 'provider'

  def index
    @provider_serials = Serial.all.limit(10) #current_user.my_list_movies.where(kind: 'episode').map {|e| e.season.serial}
  end

  def new
    @provider_serial = Serial.new
  end

  def choose_mode
    @serials = Serial.all
  end

  def show
  end

  def edit
    #code
  end

  def create
    @serial = Serial.create!(serial_params)
    SerialService.new(
      author: current_user,
      params: params,
      serial: @serial
    ).call
    unless @message
      redirect_to provider_serials_url, notice: I18n.t('flash.serial.successfully_created')
    end
  end

  def update
    params[:serial][:year] = params[:serial][:year].gsub("/", "-")
    SerialService.new(
      author: current_user,
      params: params,
      serial: @provider_serial
    ).check_seasons
    if @provider_serial.update(serial_params)
      save_serial_thumbnails(@provider_serial)

      redirect_to provider_serials_path(@provider_serial), notice: I18n.t('flash.serial.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @provider_serial.destroy
    redirect_to provider_serials_url, notice: I18n.t('flash.serial.successfully_deleted')
  end
  private

  def set_provider_serial
    @provider_serial = Serial.friendly.find(params[:id])
  end

  def serial_params
    params.require(:serial).permit( :title, :year, :description, :provider_genre_id, :directed_by, :language, :star_cast, :seasons_number, serial_thumbnail_attributes: [:id, :serial_screenshot_1, :serial_screenshot_2, :serial_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot] )
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
