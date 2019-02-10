class Admin::SerialsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_admin_serial, only: [:show, :edit,:update, :destroy]


  def index
    @admin_serials = Serial.all
  end

  def new
    @admin_serial = Serial.new
  end

  def choose_mode
    @serials = Serial.all
  end

  def new2
    @admin_serial = Serial.new
    @movie_thumbnail = @admin_serial.movie_thumbnail
    render template: 'admin/serials/pages/new2.html.erb'
  end

  def new3
    @admin_serial = Serial.find(params[:id])
    render template: 'admin/serials/pages/new3.html.erb'
  end

  def new4
    #code
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
      redirect_to admin_serials_url, notice: I18n.t('flash.serial.successfully_created')
    end
  end

  def update
    params[:serial][:year] = params[:serial][:year].gsub("/", "-")
    SerialService.new(
      author: current_user,
      params: params,
      serial: @admin_serial
    ).check_seasons
    if @admin_serial.update(serial_params)
      save_movie_thumbnails(@admin_serial)

      redirect_to admin_serials_path(@admin_serial), notice: I18n.t('flash.serial.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @admin_serial.destroy
    redirect_to admin_serials_url, notice: I18n.t('flash.serial.successfully_deleted')
  end
  private

  def set_admin_serial
    @admin_serial = Serial.friendly.find(params[:id])
  end

  def serial_params
    params.require(:serial).permit( :title, :year, :description, :admin_genre_id, :directed_by, :language, :star_cast, :seasons_number, movie_thumbnail_attributes: [:id, :movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot] )
  end

  def save_movie_thumbnails(admin_serial)
    movie_thumbnail = admin_serial.movie_thumbnail

    return unless params[:movie_thumbnail].present?

    if movie_thumbnail.present?
      movie_thumbnail.update(movie_thumbnail_params)
    else
      binding.pry
      movie_thumbnail = admin_serial.build_movie_thumbnail(movie_thumbnail_params)
      binding.pry
      movie_thumbnail.save
    end
  end

  def movie_thumbnail_params
    params.require(:movie_thumbnail).permit(:movie_screenshot_1, :movie_screenshot_2, :movie_screenshot_3, :thumbnail_screenshot, :thumbnail_640_screenshot, :thumbnail_800_screenshot)
  end

end
