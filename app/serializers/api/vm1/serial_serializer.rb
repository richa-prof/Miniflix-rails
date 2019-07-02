class Api::Vm1::SerialSerializer < ActiveModel::Serializer
  attributes :id, :title, :year

  has_one :genre, serializer: Api::V1::GenreSerializer
  has_one :movie_thumbnail, serializer: Api::V1::MovieThumbnailSerializer
  has_many :seasons, serializer: Api::Vm1::SeasonSerializer

  def year
    object.year.year
  end
end
