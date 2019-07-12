class Api::V1::FilmSchoolStudentsSessionsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def index
    film_school_students_serializer = ActiveModelSerializers::SerializableResource.new(FilmSchoolStudentsSession.all, scope: {current_user: current_user},
      each_serializer: Api::V1::FilmSchoolStudentsSessionSerializer)
    render json: { film_school_students_sessions: film_school_students_serializer }
  end

  def create
    film_school_students_session = FilmSchoolStudentsSession.new(film_school_students_sessions_params)
    if film_school_students_session.save
      film_school_student_serializer = ActiveModelSerializers::SerializableResource.new(film_school_students_session, scope: {current_user: current_user},
        serializer: Api::V1::FilmSchoolStudentsSessionSerializer).serializable_hash
      response = {success: true, film_school_students_session: film_school_student_serializer }
    else
      response = {success: false, message: film_school_student_session.errors }
    end
    render json: response
  end

  private

    def film_school_students_sessions_params
      params.require(:film_school_students_session).permit(:id, :name, :user_id, :organization_id, :ip_address, :access_token, :sign_out_time)
    end
end
