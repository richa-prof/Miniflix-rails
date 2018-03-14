class Api::V1::UserVideoLastStopsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def create
    user_video_last_stop = current_user.user_video_last_stops.find_or_initialize_by(admin_movie_id: params[:movie_id])
    user_video_last_stop.total_time = user_video_last_stop_params[:total_time]
    user_video_last_stop.last_stopped = user_video_last_stop_params[:last_stopped]
    if user_video_last_stop.save
      serialize_movies = ActiveModelSerializers::SerializableResource.new(user_video_last_stop.movie, scope: {current_user: current_user},
          serializer: Api::V1::MovieSerializer).serializable_hash
      response = {success: true, movie: serialize_movies }
    else
      response = {success: false, message: user_video_last_stop.errors }
    end
    render json: response
  end

  private

    def user_video_last_stop_params
      params.require(:user_video_last_stop).permit(:last_stopped, :total_time)
    end
end
