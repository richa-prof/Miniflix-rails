class Api::V1::GenreSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :color, :description
  has_one :seo_meta, serializer: Api::V1::SeoMetaSerializer

  def name
    object.name.capitalize
  end
end
