class Api::V1::FilmSchoolStudentsSessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :organization_id, :ip_address, :access_token, :sign_out_time
end