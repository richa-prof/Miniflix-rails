class Api::V1::MoviesController < ApplicationController

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
end
