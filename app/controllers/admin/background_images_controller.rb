class Admin::BackgroundImagesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_background_image, only: [:show, :edit, :update, :destroy]
  layout 'admin'

  def index
    @background_images = BackgroundImage.all
  end

  def new
     @background_image = BackgroundImage.new
     puts "@background_image  #{@background_image.to_json}"
  end

  def create
    @background_image = BackgroundImage.new(background_image_params)
    puts "@background_image  #{@background_image.to_json}"

    respond_to do |format|
      if @background_image.save
        format.html { redirect_to admin_background_images_url,
                      notice: I18n.t('flash.background_image.successfully_created') }
        format.json { render :index, status: :created, location:  @background_image }
      else
        format.html { render :new, notice: @background_image.errors.full_messages[0] }
        format.json { render json:  @background_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

   # GET /admin/genres/1/edit
  def edit
  end

  # PATCH/PUT /admin/genres/1.json
  def update
    respond_to do |format|
      if @background_image.update(background_image_params)
        format.html { redirect_to admin_background_images_url,
                      notice: I18n.t('flash.background_image.successfully_updated') }
        format.json { render :index, status: :ok, location: @background_image }
      else
        format.html { render :edit }
        format.json { render json: @background_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @background_image.destroy

    respond_to do |format|
      format.html { redirect_to admin_background_images_url,
                    notice: I18n.t('flash.background_image.successfully_deleted') }
      format.json { head :no_content }
    end
  end

  private

  def background_image_params
    params.require(:background_image).permit(:image_file, :is_set)
  end

  def set_background_image
    @background_image = BackgroundImage.find(params[:id])
  end
end
