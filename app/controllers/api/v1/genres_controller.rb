class Api::V1::GenresController < ApplicationController

  def index
    genres = Genre.joins(:movies).distinct.paginate(page: params[:page])
    render json: genres, serializer: Api::V1::CustomGenreSerializer
  end
end
