class MarketingStaff::GenresController < ApplicationController
  before_action :authenticate_marketing_staff_user!
  before_action :set_genre, only: [:show, :edit, :update]

  layout 'admin'

  # GET /admin/genres
  # GET /admin/genres.json
  def index
    @admin_genres = Genre.all
  end

  # GET /admin/genres/1
  # GET /admin/genres/1.json
  def show
  end

  # GET /admin/genres/1/edit
  def edit
  end

  # PATCH/PUT /admin/genres/1
  # PATCH/PUT /admin/genres/1.json
  def update
    respond_to do |format|
      if @admin_genre.update(admin_genre_params)
        format.html { redirect_to admin_genres_url,
                      notice: I18n.t('flash.genre.successfully_updated') }
        format.json { render :index, status: :ok, location: @admin_genre }
      else
        format.html { render :edit }
        format.json { render json: @admin_genre.errors, status: :unprocessable_entity }
      end
    end
  end

  def check_genre_name
    genre_name = params[:genre][:name]

    if genre_id.present? && genre_id == "0"
      @admin_genre = Genre.find_by_name(genre_name)
    else
      @admin_genre = Genre.where("name = ? AND id != ?", genre_name, genre_id).first
    end
         
    respond_to do |format|
      format.json { render :json => !@admin_genre }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_genre
      @admin_genre = Genre.friendly.find(genre_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_genre_params
      params.require(:genre).permit(:name, :color, :description)
    end

    def genre_id
      params[:id]
    end
end
