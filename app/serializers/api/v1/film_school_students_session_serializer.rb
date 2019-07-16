class Api::V1::FilmSchoolStudentsSessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :organization_id, :ip_address, :access_token, :sign_out_time, :sign_in_time

  def sign_out_time
    object.sign_out_time ? object.sign_out_time.strftime("%A, %d %b %Y %l:%M %p") : '-'
  end

  def sign_in_time
    object.created_at.strftime("%A, %d %b %Y %l:%M %p")
  end
end
