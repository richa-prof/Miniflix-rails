class Api::V1::FilmSchoolStudentsSessionsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.organizations.present? && current_user.organizations_users_infos.present?
      if current_user.organizations_users_infos.try(:take).try(:role).present? && current_user.organizations_users_infos.try(:take).try(:role).eql?('admin')
        film_school_students = current_user.organizations.take.film_school_students_sessions
        film_school_students_serializer = ActiveModelSerializers::SerializableResource.new(film_school_students, scope: {current_user: current_user},
          each_serializer: Api::V1::FilmSchoolStudentsSessionSerializer)
        render json: { film_school_students_sessions: film_school_students_serializer }
      else
        response = {success: false, message: 'Film school is Invalid' }
      end
    else
      response = {success: false, message: 'Film school is Invalid' }
    end
  end

  def create
    if current_user.present? && current_user.tokens[params[:film_school_student_session][:access_token]]
      params[:film_school_student_session][:user_id] = current_user.id
      if current_user.organizations.present?
        params[:film_school_student_session][:organization_id] = current_user.organizations.try(:take).id
        film_school_student_session = FilmSchoolStudentsSession.new(film_school_students_sessions_params)
        if film_school_student_session.save
          film_school_student_serializer = ActiveModelSerializers::SerializableResource.new(film_school_student_session, scope: {current_user: current_user},
            serializer: Api::V1::FilmSchoolStudentsSessionSerializer).serializable_hash
          response = {success: true, film_school_student_session: film_school_student_serializer }
        else
          response = {success: false, message: film_school_student_session.errors }
        end
        render json: response
      else
        response = {success: false, message: 'Invalid user' }
      end
    else
      response = {success: false, message: 'Invalid user' }
    end
  end

  private

    def film_school_students_sessions_params
      params.require(:film_school_student_session).permit(:id, :name, :user_id, :organization_id, :ip_address, :access_token, :sign_out_time)
    end
end
