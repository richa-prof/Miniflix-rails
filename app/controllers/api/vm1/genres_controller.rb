class Api::Vm1::GenresController < Api::Vm1::ApplicationController
  include UsersHelper
  before_action :authenticate_according_to_devise, except: [:genres]
  #get all gener
  def genres
    begin
      @genres = Genre.all.order(:name)
      if @genres.present?
        @response = { code: "0",status: "Success",message: "Successfully genres found",genres: @genres.as_json(only: [:id, :name, :color])}
      else
        @response = { code: "1",status: "Error",message: "No any genres found"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  #get all gener with movie
  def genres_wise_movies
    begin
      @genres = Genre.joins(:movies).distinct.order(:name)
      @recentaly_watched = []
      if params[:user_id] != "0" && params[:user_id].present?
        @user = User.find(params[:user_id])
        if @user
          @recentaly_watched = @user.user_video_last_stops.map do |user_video_last_stop|
            create_json_recentaly_watched user_video_last_stop
          end
        end
      elsif params[:device_id].present?
        @user = Visitor.find_by_device_id(params[:device_id])
        if @user
          @recentaly_watched = @user.user_video_last_stops.map do |user_video_last_stop|
            create_json_recentaly_watched user_video_last_stop
          end
        end
      end
      if @genres.present? && Movie.exists?
        @genres=@genres.map do |genre|
          create_json_genres_with_movie genre
        end
        @response = { code: "0",status: "Success",message: "Successfully genere with movie found",genres: @genres,recentaly_watched: @recentaly_watched}
      else
        @response = { code: "1",status: "Error",message: "No any genres found"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  # Give all genre and one latest movie for each genre
  # GET `genres/genres_with_latest_movie`
  def genres_with_latest_movie
    begin
      @genres = Genre.joins(:movies).distinct.order(:name)
      @recentaly_watched = []

      if params[:user_id] != "0" && params[:user_id].present?
        @user = User.find(params[:user_id])
        if @user
          @recentaly_watched = @user.user_video_last_stops.map do |user_video_last_stop|
            create_json_recentaly_watched user_video_last_stop
          end
        end
      elsif params[:device_id].present?
        @user = Visitor.find_by_device_id(params[:device_id])
        if @user
          @recentaly_watched = @user.user_video_last_stops.map do |user_video_last_stop|
            create_json_recentaly_watched user_video_last_stop
          end
        end
      end
      if @genres.present? && Movie.exists?
        @genres = @genres.map do |genre|
                    prepare_genres_with_latest_movie_json(genre)
                  end

        @response = { code: "0",
                      status: "Success",
                      message: 'Successfully genere with latest movie found',
                      genres: @genres,
                      recentaly_watched: @recentaly_watched }
      else
        @response = { code: "1",
                      status: "Error",
                      message: "No any genres found" }
      end
    rescue Exception => e
      @response = { :code => "-1",
                    :status => "Error",
                    :message => e.message }
    end

    render json: @response
  end

  # POST `genres/id_wise_gener`
  def id_wise_gener_with_movie
    begin
      @genre = Genre.find(params[:id])
      if @genre
        @movies = @genre.movies.order(created_at: :desc).offset(params[:offset]).limit(params[:limit]).map {|s| s&.format(mode: 'short')}.uniq
        @genre = {id: @genre.id,name: @genre.name,color: @genre.color.to_s, movies: @movies}
        @response = { code: "0",status: "Success",message: "Successfully genere with movie found",genre: @genre}
      else
        @response = { code: "1",status: "Error",message: "No any genres found"}
      end
    rescue Exception => e
      @response = {:code => "-1",:status => "Error",:message => e.message}
    end
    render json: @response
  end

  def create_json_genres genres
    return {id: genres.id,name: genres.name,color: genres.color.to_s}
  end

  def create_json_genres_with_movie genre
    @movies = genre.movies.order(:name).limit(5)
    return {id: genre.id,name: genre.name,color: genre.color.to_s,movies: @movies.as_json("genre_wise_list")}
  end

  def create_json_recentaly_watched user_video_last_stop
    admin_movie = user_video_last_stop.movie
    film_video_url = "https://s3-us-west-1.amazonaws.com/#{ENV['S3_INPUT_BUCKET']}/#{admin_movie.movie_versions.find_by_resolution("320").film_video}"
    {id: user_video_last_stop.id,movie_id: admin_movie.id,last_stopped: user_video_last_stop.last_stopped.to_i,watched_percent: user_video_last_stop.watched_percent,time_left_text: user_video_last_stop.time_left,image_330: image_cloud_front_url(admin_movie.movie_thumbnail.thumbnail_screenshot.carousel_thumb.path),image_640: image_cloud_front_url(admin_movie.movie_thumbnail.thumbnail_640_screenshot.carousel_thumb.path),film_video: film_video_url,current_time: user_video_last_stop.current_time,remaining_time: user_video_last_stop.remaining_time,updated_at: user_video_last_stop.formated_updated_at, captions: admin_movie.movie_captions.as_json}
  end

  def prepare_genres_with_latest_movie_json(genre)
    movie = genre.movies.last

    return { id: genre.id,
             name: genre.name,
             color: genre.color.to_s,
             latest_movie: movie.as_json('genres_with_latest_movie')
           }
  end
end
