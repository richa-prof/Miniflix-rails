class Api::Vm1::SerialsController < Api::Vm1::ApplicationController
  before_action :authenticate_api, only: []
  #before_action :authenticate_according_to_devise, only: [:get_serial_detail, :manage_like, :my_list ]

  def limit
    params[:limit].to_i.zero? ? Serial::PER_PAGE : params[limit].to_i
  end

  # /serials/getData
  def get_data
    begin

      data = {
        topSerials: Serial.fetch_top_watched_serials(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq,
        recentlyWatched:  Serial.fetch_recent_watched_serials(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq,
        new: Serial.fetch_new_serials(limit: limit).map {|s| s&.format(mode: 'compact')}.uniq,
        genres: Serial.collect_genres_data
      }
      api_response = {code: "0", status: "Success", data: data}
    rescue Exception => e
      api_response = {code: "-1", status: "Error", message: e.message}
    end
    render json: api_response
  end

  # /serials/getSerial
  def get_serial_detail
    begin
      serial = Serial.find(params[:serial_id]) 
      valid_user = api_user.try(:check_login) || false
      #p api_user.inspect  # FIXME - user not found
      data = serial.format(user: api_user, mode: 'full')
      api_response =  {:code => "0", :status => "Success", data: data }
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end

  # /serials/manageLike
  def manage_like
    begin
      serial = Serial.find(params[:serial_id]) 
      valid_user = api_user.try(:check_login) || false
      serial.mark_as_liked_by_user(api_user)
      api_response =  {:code => "0", :status => "Success"}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end

  # /serials/myList
  def my_list
    begin
      data = []
      valid_user = api_user.try(:check_login) || false
      fav_serials_ids  = []
      raise 'User not found or not logged in' unless valid_user
      api_user.favorite_episodes.limit(limit).offset(params[:skip].to_i).each do |ep|
         fav_serials_ids << ep.season&.serial&.id if ep.kind == 'episode'
      end
      p fav_serials_ids
      fav_serials = Serial.where("id in (:ids)", ids: fav_serials_ids.uniq)
      fav_serials.each do |serial|
        data << serial.format(mode: 'compact')
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
      data = []
      valid_user = api_user.try(:check_login) || false
      fav_serials_ids  = []
      p params[:searchString]
      serials = Serial.where('title LIKE ?', "%#{params[:searchString]}%").limit(limit).offset(params[:skip].to_i)

      serials.each do |serial|
        data << serial.format(mode: 'compact')
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
      genre = Genre.find(params[:genre_id])
      data = {
        genre_data: {
          id: genre&.id, 
          name: genre&.name
        },
        serials: []
      }
      #valid_user = api_user.try(:check_login) || false
      serials = Serial.where("admin_genre_id = :genre_id", genre_id: params[:genre_id]).limit(limit).offset(params[:skip].to_i)
      serials.each do |serial|
        data[:serials] << serial.format(mode: 'compact')
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
      data = []
      serials = Serial.fetch_new_serials(limit: limit, offset: params[:skip].to_i).uniq
      serials.each do |serial|
        data << serial.format(mode: 'compact')
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
      data = []
      #valid_user = api_user.try(:check_login) || false
      serials = Serial.fetch_recent_watched_serials(limit: limit, offset: params[:skip].to_i).uniq
      serials.each do |serial|
        data << serial.format(mode: 'compact')
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
      #valid_user = api_user.try(:check_login) || false
      episode = Episode.find(params[:episode_id])
      data = {
        serial: episode.season.serial.format(mode: 'compact'),
        selected_episode: episode.format(mode: 'full'),
        next_episodes: episode.next&.map {|ep| ep.format('full')}
      } 
      api_response =  {:code => "0", :status => "Success", data: data}
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: api_response
  end
end
