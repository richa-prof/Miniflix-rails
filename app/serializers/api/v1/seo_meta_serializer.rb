class Api::V1::SeoMetaSerializer < ActiveModel::Serializer
  attributes :id, :browser_title, :keywords, :description

  def keywords
    object.meta_keywords
  end

  def description
    object.meta_description
  end
end
