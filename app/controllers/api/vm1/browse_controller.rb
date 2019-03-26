class Api::Vm1::BrowseController < Api::Vm1::ApplicationController
  before_action :authenticate_api, only: []

  def limit
    params[:limit].to_i.zero? ? Serial::PER_PAGE : params[limit].to_i
  end

  # /browse/getData
  def get_data
    begin
      top_serials = Serial.fetch_top_watched_serials(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq
      top_movies = Movie.top_watched(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq
      recent_serials = Serial.fetch_recent_watched_serials(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq
      recent_movies = Movie.recently_watched(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq
      new_serials = Serial.fetch_new_serials(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq
      new_movies = Movie.new_entries(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq
      genre_data = Serial.collect_genres_data(mode: 'with_movies')
      data = {
        top: top_serials + top_movies,
        recentlyWatched:  recent_serials + recent_movies,
        new: new_serials + new_movies,
        genres: genre_data
      }
      api_response = {code: "0", status: "Success", data: data}
    rescue Exception => e
      api_response = {code: "-1", status: "Error", message: e.message}
    end
    render json: api_response
  end

 

  # /browse/getDataForGenre
  def get_data_for_genre
    begin
      genre = Genre.find(params[:genre_id])
      serials = Serial.where("admin_genre_id = :genre_id", genre_id: params[:genre_id]).limit(limit).offset(params[:skip].to_i).map{|s| s.format(mode: 'compact')}
      movies  = Movie.where("admin_genre_id = :genre_id", genre_id: params[:genre_id]).limit(limit).offset(params[:skip].to_i).map{|m| m.format(mode: 'compact')}
      data = {
        genre_data: {
          id: genre&.id, 
          name: genre&.name
        },
        data: serials + movies
      }
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


  # /browse/getDataForNew
  def get_data_for_new
    begin
      serials = Serial.fetch_new_serials(limit: limit, offset: params[:skip].to_i).uniq.map{|s| s.format(mode: 'compact')}
      movies = Movie.new_entries.map{|m| m.format(mode: 'compact')}
      api_response =  {:code => "0", :status => "Success", data: serials + movies}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


  # /browse/getDataForRecent
  # at least one movie / serial 
  def get_data_for_recent
    begin
      data = []
      serials = Serial.fetch_recent_watched_serials(limit: limit, offset: params[:skip].to_i).uniq.map{|s| s.format(mode: 'compact')}
      movies = Movie.recently_watched.map{|m| m.format(mode: 'compact')}
      api_response =  {:code => "0", :status => "Success", data: serials + movies}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


end
