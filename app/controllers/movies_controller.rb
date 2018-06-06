class MoviesController < ApplicationController

  def show
    @movie = Movie.friendly.find(params[:id])
  end
end
