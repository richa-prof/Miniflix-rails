class Api::V1::MoviesController < Api::V1::ApplicationController
  before_action :authenticate_user!, except: [:index, :featured_movie, :search, :show]

  def index
    movies = Movie.where(admin_genre_id: params[:genre_id]).paginate(page: params[:page])
    render json: serialize_movie_response_with_pagination(movies)
  end

  def featured_movie
    featured_movie = Movie.featured.last
    featured_movie ||= Movie.last
    render json: featured_movie, scope: {current_user: current_user}
  end

  def show
    movie = Movie.friendly.find(params[:id])
    render json: movie, scope: {current_user: current_user}
  end

  def search
    movies = Movie.search(params[:search_key])
    render json: movies, scope: {current_user: current_user}
  end

  def add_and_remove_to_my_playlist
    filmlist = current_user.find_or_initialize_filmlist(params[:id])
    if filmlist.new_record?
      filmlist.save
      response = { success: true ,message: "Movie successfully added to my list", is_liked: true, movie_id: params[:id]  }
    else
      filmlist.destroy
      response = { success: true ,message: "Movie successfully removed form playlist", is_liked: false,  movie_id: params[:id] }
    end
    render json: response
  end

  def my_playlist
    movies = current_user.my_list_movies.paginate(page: params[:page])
    render json: serialize_movie_response_with_pagination(movies)
  end

  def popular_movies
    movies = Movie.last 3
    render json: movies, scope: {current_user: current_user}
  end

  private
    def serialize_movie_response_with_pagination(movies)
      serialize_movies = ActiveModelSerializers::SerializableResource.new(movies, scope: {current_user: current_user},
          each_serializer: Api::V1::MovieSerializer)
      {total_page: movies.total_pages, current_page: movies.current_page, movies: serialize_movies}
    end

end
