class Api::V1::GenreSerializer < ActiveModel::Serializer
  attributes :id, :name, :color
end
