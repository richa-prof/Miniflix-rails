class Api::V1::SessionsController < DeviseTokenAuth::SessionsController
  include Api::V1::Concerns::UserSerializeDataConcern

  def render_create_success
    render json: {
      success: true,
      user:   serialize_user
    }
  end

  def destroy
    if @resource.registration_plan.eql?('FilmSchool') &&
      @resource.organizations_users_infos.present? &&
      @resource.organizations_users_infos.take.role.eql?('student')
      @film_school_student = @resource.film_school_students_sessions.find_by(access_token: @client_id)
      @film_school_student.update(sign_out_time: Time.now)
    end
    super
  end
end
