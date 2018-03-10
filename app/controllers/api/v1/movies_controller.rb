class Api::V1::MoviesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :featured_movie, :search]

  def index
    movies = Movie.where(admin_genre_id: params[:genre_id]).paginate(page: params[:page])
    serialize_movies = ActiveModelSerializers::SerializableResource.new(movies, scope: {current_user: current_user},
        each_serializer: Api::V1::MovieSerializer)
    render json: {total_page: movies.total_pages, current_page: movies.current_page, movies: serialize_movies}
  end

  def featured_movie
    featured_movie = Movie.featured.last
    featured_movie ||= Movie.last
    render json: featured_movie, scope: {current_user: current_user}
  end

  def search
    movies = Movie.search(params[:search_key])
    render json: movies, scope: {current_user: current_user}
  end

  def add_to_playlist
    filmlist = current_user.user_filmlists.new(admin_movie_id: params[:id])
    if filmlist.save
      response = { success: true ,message: "Movie successfully added to my list" }
    else
      response = { success: false ,message: filmlist.errors.full_messages }
    end
    render json: response
  end

end
