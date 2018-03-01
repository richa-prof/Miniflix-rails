class Api::V1::GenresController < ApplicationController

  def index
    if params[:paginate]
      genres = Genre.joins(:movies).distinct.paginate(page: params[:page])
      render json: genres, serializer: Api::V1::CustomGenreSerializer
    else
      genres = Genre.joins(:movies).distinct
      render json: genres
    end
  end
end
