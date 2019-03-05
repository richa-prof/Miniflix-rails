class Api::Vm1::SerialsController < Api::Vm1::ApplicationController
  before_action :authenticate_api, only: []
  before_action :authenticate_according_to_devise, only: []

  # /serials/getSerial
  def get_serial_detail
    begin
      serial = Serial.find(params[:id]) 
      serial_hash = serial.formatted_response('full_serial_model')
      api_response =  {:code => "0", :status => "Success", data: serial_hash }
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


  # /serials/getData
  def get_data
    begin
      Serial.find_each do |serial|
        serial_hash = serial.formatted_response('short_serial_model')
      end

      data = {
        topSerials: Serial.all,
        recentlyWatched:  Serial.re@current_user.user_video_last_stops,
        new: Serial.new_serials
        genres: get_genres_data
      }
      api_response = { code: "0", status: "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
  end

  def manage_like
    begin
      serial = Serial.find(params[:id]) 
      valid_user = api_user.try(:check_login) || false
      serial.season.movies.each do |movie|
        valid_user.my_list_movies << movie
      end
      api_response =  {:code => "0", :status => "Success"}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end

  # /serials/myList
  def my_list
    begin
      valid_user = api_user.try(:check_login) || false
      fav_serials_ids  = []
      valid_user.my_list_movies.find_each(start: params[:skip]).limit(50) do |movie|
         fav_serials_ids << movie.season&.serial&.id
      end
      fav_serials = Serial.where("id in :ids", ids: fav_serials_ids.uniq)
      fav_serials.each do |serial|
        data << serial.formatted_response('short_serial_model')
      end
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end

  # /serials/search
  def search
    begin
      valid_user = api_user.try(:check_login) || false
      fav_serials_ids  = []
      Movie.all.find_each do |movie|
         fav_serials_ids << movie.season&.serial&.id
      end
      serials = Serial.where("id IN :ids AND name LIKE :search", ids: fav_serials_ids.uniq, search: "%params[:searchString]%")
      serials.each do |serial|
        data << serial.formatted_response('short_serial_model')
      end
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


  # /serials/getDataForGenre
  def get_data_for_genre
    begin
      valid_user = api_user.try(:check_login) || false
      genre_serials_ids  = []
      Movie.all.find_each(start: params[:skip]) do |movie|
         genre_serials_ids << movie.season&.serial&.id
      end
      serials = Serial.where("id IN :ids AND genre_id = :genre_id", ids: fav_serials_ids.uniq, genre_id: params[:genre_id])
      serials.each do |serial|
        data << serial.formatted_response('short_serial_model')
      end
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


  # /serials/getDataForNew
  def get_data_for_new
    begin
      valid_user = api_user.try(:check_login) || false
      serials_ids  = []
      Movie.new_movies.find_each(start: params[:skip]) do |movie|
         serials_ids << movie.season&.serial&.id
      end
      serials = Serial.where("id IN :ids AND genre_id = :genre_id", ids: serials_ids.uniq, genre_id: params[:genre_id])
      serials.each do |serial|
        data << serial.formatted_response('short_serial_model')
      end
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end


  # /serials/getDataForRecent
  # хоча б один фільм
  def get_data_for_recent
    begin
      valid_user = api_user.try(:check_login) || false
      serials_ids  = []
      Movie.recent.find_each(start: params[:skip]) do |movie|
         serials_ids << movie.season&.serial&.id
      end
      serials = Serial.where("id IN :ids AND genre_id = :genre_id", ids: serials_ids.uniq, genre_id: params[:genre_id])
      serials.each do |serial|
        data << serial.formatted_response('short_serial_model')
      end
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end

  # /serials/getEpisodeDetails
  def get_episode_details
    begin
      valid_user = api_user.try(:check_login) || false
      serials_ids  = []
      Movie.recent.find_each(start: params[:skip]) do |movie|
         serials_ids << movie.season&.serial&.id
      end
      serials = Serial.where("id IN :ids AND genre_id = :genre_id", ids: serials_ids.uniq, genre_id: params[:genre_id])
      serials.each do |serial|
        data << serial.formatted_response('short_serial_model')
      end
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end

  

end
