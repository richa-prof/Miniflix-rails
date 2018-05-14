class Admin::MovieCaptionsController < ApplicationController
  before_action :set_movie
  layout 'admin'

  def index
    @movie_captions = @admin_movie.movie_captions
    caption_data = @movie_captions.active_caption.collect{|e| e.as_json}
  end

  def new
    @movie_caption = @admin_movie.movie_captions.new
  end

  def create
    @movie_caption = @admin_movie.movie_captions.new(movie_caption_params)
    if @movie_caption.save
      redirect_to( edit_admin_movie_movie_caption_path( @admin_movie, @movie_caption ),
                   notice: I18n.t('flash.movie_caption.caption_file.successfully_created') )
    else
      render :new
    end
  end

  def edit
    @movie_caption = @admin_movie.movie_captions.find(params[:id])
  end

  def update
    @movie_caption = @admin_movie.movie_captions.find(params[:id])
    @movie_caption.update_caption = true
    if movie_caption_params[:is_default] == "1"
      default_set_movies = @admin_movie.movie_captions.default_caption
      default_set_movies.update_all(is_default: false) if default_set_movies.present?
    end
    if @movie_caption.update_attributes(movie_caption_params)
      if params[:commit] == "Save"
        redirect_to( admin_movie_movie_captions_path(@admin_movie),
                     notice: I18n.t('flash.movie_caption.caption_file.successfully_saved') )
      else
        redirect_to new_admin_movie_movie_caption_path(@admin_movie)
      end
    else
      render :edit
    end
  end

  def destroy
     @movie_caption = @admin_movie.movie_captions.find(params[:id])
     @movie_caption.destroy
     redirect_to( admin_movie_movie_captions_path(@admin_movie),
                  notice: I18n.t('flash.movie_caption.caption_file.successfully_deleted') )
  end

  private

  def movie_caption_params
    params.require(:movie_caption).permit(:caption_file, :language, :status, :is_default) if params[:movie_caption].present?
  end

  def set_movie
    @admin_movie = Movie.friendly.find(params[:movie_id])
  end
end
