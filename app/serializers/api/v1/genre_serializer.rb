class Api::V1::GenreSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :color

  def name
    object.name.capitalize
  end
end
