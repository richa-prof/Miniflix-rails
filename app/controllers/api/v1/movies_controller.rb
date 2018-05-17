class Api::V1::MoviesController < Api::V1::ApplicationController
  before_action :set_genre, only: [:index]
  before_action :authenticate_user!, except: [:index, :featured_movie, :search, :show, :battleship]

  def index
    movies = @genre.movies.paginate(page: params[:page])
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
    movies = Movie.search(params[:search_key]).paginate(page: params[:page])
    render json: serialize_movie_response_with_pagination(movies)
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

  def battleship
    movies = Movie.battleship_movies
    serialize_movies = ActiveModelSerializers::SerializableResource.new(movies, scope: {current_user: current_user},
        each_serializer: Api::V1::MovieSerializer)

    render json: { movies: serialize_movies }
  end

  private
    def serialize_movie_response_with_pagination(movies)
      serialize_movies = ActiveModelSerializers::SerializableResource.new(movies, scope: {current_user: current_user},
          each_serializer: Api::V1::MovieSerializer)
      {total_page: movies.total_pages, current_page: movies.current_page, movies: serialize_movies}
    end

    def set_genre
      @genre = Genre.friendly.find params[:genre_id]
    end

end
