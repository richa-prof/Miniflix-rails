class Api::Vm1::MoviesController < Api::Vm1::ApplicationController
  include UsersHelper
  before_action :authenticate_api, only: [:my_list_movies, :add_movie_my_list, :remove_my_list_movie]
  before_action :authenticate_according_to_devise, only: [:get_movie_detail, :get_all_movie_by_movie_name_or_genre_name, :search_movie_with_genre, :add_to_recently_watched, :add_to_recently_watched_visitor, :add_multiple_to_recently_watched, :latest_movies ]


  def get_movie_detail
    user_video_last_stop = api_user.user_video_last_stops.find_by(admin_movie_id: params[:id]) if api_user
    last_stopped = (user_video_last_stop.present? ? user_video_last_stop.last_stopped : 0)
    begin
      movie = Movie.find(params[:id])
      valid_payment = api_user.try(:check_login) || false
      movie_hash = movie.as_json("full_movie_detail").merge(is_valid_payment: valid_payment, is_active: movie.movie_view_by_user?(api_user.try(:id)), last_stopped: last_stopped)
      api_response = { code: "0",status: "Success",message: "Successfully  movie details found", movie: movie_hash }
    rescue Exception => e
      api_response = {:code => "-1",:status => "Error",:message => e.message, movie: []}
    end
    render json: api_response
  end

  def get_all_movie_by_movie_name_or_genre_name
    begin
      if params[:movie_name]
        @movies = Movie.where("lower(name) LIKE (?) ","%#{params[:movie_name].downcase}%").offset(params[:offset]).limit(params[:limit])
        if @movies.present?
          @response = { code: "0",status: "Success",message: "Successfully  movie found", movies: @movies.as_json}
        else
          @response = { code: "0",status: "Success",message: "Not found",  movies: [] }
        end
      else
        @genres = Genre.where("lower(name) LIKE (?) ","%#{params[:genre_name].downcase}%")
        if @genres.present?
          @genres= @genres.map do |genre|
            create_json_genres genre
          end
          @response = { code: "0",status: "Success", message: "Successfully genere Found", genres: @genres}
        else
          @response = { code: "0",status: "Success",message: "No any genres not found",  genres: []}
        end
      end
    rescue Exception => e
      @response = {:code => "-1", :status => "Error", :message => e.message}
    end
    render json: @response
  end


  #serch movie with genre name
  def search_movie_with_genre
    begin
      if params[:movie_name].present? && params[:genre_id].present?
        @movies=Movie.where("lower(name) LIKE (?) ","%#{params[:movie_name].downcase}%").where(admin_genre_id: params[:genre_id])
        if @movies.present?
          @response = { code: "0",status: "Success",message: "Successfully  movie found", movies: @movies.as_json(api_user)}
        else
          @response = { code: "0", status: "Success", message: "Not found", movies: []}
        end
      else
        @movies = Movie.where(admin_genre_id: params[:genre_id])
        if @movies.present?
          @response = { code: "0",status: "Success", message: "Successfully  movie found", movies: @movies.as_json(api_user)}
        else
          @response =  { code: "0", status: "Success", message: "Not found", movies: []}
        end
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message, movies: []}
    end
    render json: @response
  end

  def add_movie_my_list
    filmlist = api_user.user_filmlists.find_by_admin_movie_id(params[:movie_id])
    if filmlist.present?
      api_response = { code: "3",status: "Error",message: "Movie already added to my list", filmlist: filmlist }
    else
      begin
        movie = Movie.find params[:movie_id]
        api_user.user_filmlists.create!(admin_movie_id: params[:movie_id])
        mdata = movie.as_json.merge!(last_stopped: movie.fetch_last_stop(api_user))
        api_response = { code: "0",status: "Success",message: "Movie added successfully to my list", movie: mdata}
      rescue Exception => e
        api_response = {:code => "-1",:status => "Error",:message => e.message, movie: []}
      end
    end
    render json: api_response
  end


  def my_list_movies
    begin
      my_movies = Movie.joins(:user_filmlists).where('user_filmlists.user_id = ?', api_user.id).order('user_filmlists.created_at DESC').offset(params[:offset]).limit(params[:limit])
      if my_movies.present?
        api_response = { code: "0",status: "Success",message: "Successfully get all movies for my list", my_movies: my_movies.as_json(api_user)}
      else
        api_response = { code: "0",status: "Success",message: "No any my list movie found",   my_movies: []}
      end
    rescue Exception => e
      api_response = {code: "-1", status: "Error", message: e.message, notification: []}
    end
    render json: api_response
  end


  def remove_my_list_movie
    my_movie = api_user.user_filmlists.find_by_admin_movie_id (params[:movie_id])
    api_response = if my_movie.present?
       my_movie.delete
      { code: "0",status: "Success",message: "Movie successfully removed from your list", my_movie: my_movie}
    else
      { code: "0",status: "Success", message: "Movie not found in your list", my_movie: [] }
    end
    render json: api_response
  end

  # add movie in recently watched
  def add_to_recently_watched
    begin
      if params[:movie_id].present? && params[:current_time].present? && params[:total_time].present? && (params[:user_id].present? || params[:device_id].present?)
        if params[:user_id].present?
          @current_user = User.find(params[:user_id])
        else
          @current_user = Visitor.find_or_create_by(device_id: params[:device_id])
        end
        @user_video_last_stop = @current_user.user_video_last_stops.find_by(admin_movie_id: params[:movie_id])
        last_stopped = UserVideoLastStop.convert_time_to_seconds(params[:current_time])
        total_time = UserVideoLastStop.convert_time_to_seconds(params[:total_time])
        puts"==========#{last_stopped}========#{total_time}==========="
        watched_percent = (last_stopped * 100)/total_time
        if @user_video_last_stop.present?
          @user_video_last_stop.update(last_stopped: last_stopped,total_time: total_time,watched_percent: watched_percent)
        else
          @user_video_last_stop = @current_user.user_video_last_stops.create(last_stopped: last_stopped,total_time: total_time,watched_percent: watched_percent,admin_movie_id: params[:movie_id])
        end
        @user_video_last_stop = create_json_recentaly_watched @user_video_last_stop
        @response = { code: "0",status: "Success",message: "Successfully added/updated to recently watched list", movie: @user_video_last_stop}
      else
        @response = {:code => "0",:status => "Success",:message => "Please pass valid parameteres"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  # add movie in recently watched of visitor
  def add_to_recently_watched_visitor
    begin
      if params[:movie_id].present? && params[:current_time].present? && params[:device_id].present? && params[:total_time].present?
        @visitor = Visitor.find_or_create_by(device_id: params[:device_id])

        @user_video_last_stop = @visitor.user_video_last_stops.find_by(admin_movie_id: params[:movie_id])
        last_stopped = UserVideoLastStop.convert_time_to_seconds(params[:current_time])
        total_time = UserVideoLastStop.convert_time_to_seconds(params[:total_time])
        puts"==========#{last_stopped}========#{total_time}==========="
        watched_percent = (last_stopped * 100)/total_time
        if @user_video_last_stop.present?
          @user_video_last_stop.update(last_stopped: last_stopped,total_time: total_time,watched_percent: watched_percent)
        else
          @user_video_last_stop = @visitor.user_video_last_stops.create(last_stopped: last_stopped,total_time: total_time,watched_percent: watched_percent,admin_movie_id: params[:movie_id])
        end
        @user_video_last_stop = create_json_recentaly_watched @user_video_last_stop
        @response = { code: "0",status: "Success",message: "Successfully added/updated to recently watched list",movie: @user_video_last_stop}
      else
        @response = {:code => "0",:status => "Success",:message => "Please pass valid parameteres", movie: []}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  # add multiple movie in recently watched
  def add_multiple_to_recently_watched
    begin
      if params[:movie_list].present? && (params[:user_id].present? || params[:device_id].present?)
        if params[:user_id].present?
          @current_user = User.find(params[:user_id])
        else
          @current_user = Visitor.find_or_create_by(device_id: params[:device_id])
        end
        @recently_watched_movies = []
        @not_added = []
        params[:movie_list].each_with_index do |movie,index|
          if movie[:movie_id].present? && movie[:current_time].present?  && movie[:total_time].present?
            @user_video_last_stop = @current_user.user_video_last_stops.find_by(admin_movie_id:  movie[:movie_id])
            last_stopped = UserVideoLastStop.convert_time_to_seconds( movie[:current_time])
            total_time = UserVideoLastStop.convert_time_to_seconds( movie[:total_time])
            watched_percent = (last_stopped * 100)/total_time
            if @user_video_last_stop.present?
              @user_video_last_stop.update(last_stopped: last_stopped,total_time: total_time,watched_percent: watched_percent)
            else
              @user_video_last_stop = @current_user.user_video_last_stops.create(last_stopped: last_stopped,total_time: total_time,watched_percent: watched_percent,admin_movie_id: movie[:movie_id])
            end
            @recently_watched_movies.push(create_json_recentaly_watched @user_video_last_stop)
          else
            @not_added.push(movie[:movie_id].to_s)
          end
        end # loop
        @response = { code: "0",status: "Success",message: "Successfully added/updated to recently watched list", adde_movies: @recently_watched_movies, not_added_movie_ids: @not_added}
      else
        @response = {:code => "0",:status => "Success", :msg => "Please pass movie_list/user_id", adde_movies: [], not_added_movie_ids: []}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:msg => e.message}
    end
    render json: @response
  end

  def get_watched_movie_count_visitor
    begin
      if params[:device_id].present?
        @visitor = Visitor.find_by_device_id(params[:device_id])
        @visitor.try(:user_video_last_stops).try(:count).to_i
        @response = { code: "0",status: "Success",message: "Watched movie count of visitor", watched_movie_count: @visitor.try(:user_video_last_stops).try(:count).to_i}
      else
        @response = {:code => "0",:status => "Success",:message => "Please pass device_id"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  def latest_movies
    movies = Movie.order(created_at: :desc).limit params[:limit]
    response =  { code: "0",status: "Success" ,movies: movies.as_json(api_user)}
    render json: response
  end

  def create_json_genres genres
    return {id: genres.id,name: genres.name,color: genres.color.to_s}
  end

  def create_json_recentaly_watched user_video_last_stop
    @admin_movie = user_video_last_stop.movie
    film_video_url = "https://s3-us-west-1.amazonaws.com/#{ENV['S3_INPUT_BUCKET']}/#{@admin_movie.movie_versions.find_by(resolution: "320").film_video}"
    return {id: user_video_last_stop.id,movie_id: @admin_movie.id,last_stopped: user_video_last_stop.last_stopped.to_i,watched_percent: user_video_last_stop.watched_percent,time_left_text: user_video_last_stop.time_left,image_330: image_cloud_front_url(@admin_movie.movie_thumbnail.thumbnail_screenshot.carousel_thumb.path),image_640: image_cloud_front_url(@admin_movie.movie_thumbnail.thumbnail_640_screenshot.carousel_thumb.path),film_video: film_video_url,current_time: user_video_last_stop.current_time,remaining_time: user_video_last_stop.remaining_time,updated_at: user_video_last_stop.formated_updated_at, captions: @admin_movie.movie_captions.as_json}
  end
end
