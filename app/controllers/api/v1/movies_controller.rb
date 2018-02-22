class Api::V1::MoviesController < ApplicationController
  def featured_movie
    featured_movie = Movie.featured.last
    featured_movie ||= Movie.last
    render json: featured_movie
  end
end
