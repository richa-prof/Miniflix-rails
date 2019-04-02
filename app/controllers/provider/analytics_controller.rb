class Provider::AnalyticsController < ApplicationController

  #before_action :authenticate_provider_user!

  layout 'provider'

  def index
    @provider_movies = Movie.all.limit(10)  #current_user.my_list_movies
    #redirect_to action: :new
  end

end
