class Api::V1::MoviesController < Api::V1::ApplicationController
  before_action :set_genre, only: [:index]
  before_action :authenticate_user!, except: [:index, :featured_movie, :search, :show, :battleship]

  def index
    movies = @genre.movies.where("s3_multipart_upload_id IS NOT NULL").paginate(page: params[:page])
    seo_meta_data = serialize_seo_meta(@genre)
    movies_data = serialize_movie_response_with_pagination(movies)
    render json: movies_data.merge({seo_meta: seo_meta_data})
  end

  def featured_movie
    featured_movie = Movie.featured.last
    featured_movie ||= ((Movie.last.s3_multipart_upload_id != nil) ? Movie.last : Movie.where("s3_multipart_upload_id IS NOT NULL").last)
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
    movies = Movie.popular_movies(3)
    render json: movies, scope: {current_user: current_user}
  end

  def battleship
    max_count = params[:video_count]
    movies = Movie.battleship_movies
    if max_count.present?
      movies = movies.first(max_count.to_i)
    end

    serialize_movies = ActiveModelSerializers::SerializableResource.new(movies, scope: {current_user: current_user},
        each_serializer: Api::V1::BattleshipMovieSerializer)

    render json: { movies: serialize_movies }
  end

  private
    def serialize_movie_response_with_pagination(movies)
      serialize_movies = ActiveModelSerializers::SerializableResource.new(movies, scope: {current_user: current_user},
          each_serializer: Api::V1::MovieSerializer)
      {total_page: movies.total_pages, current_page: movies.current_page, movies: serialize_movies}
    end

    def serialize_seo_meta(genre)
      seo_meta_obj = genre.seo_meta

      return unless seo_meta_obj.persisted?

      ActiveModelSerializers::SerializableResource.new(seo_meta_obj,
      each_serializer: Api::V1::SeoMetaSerializer)
    end

    def set_genre
      @genre = Genre.friendly.find params[:genre_id]
    end

end
