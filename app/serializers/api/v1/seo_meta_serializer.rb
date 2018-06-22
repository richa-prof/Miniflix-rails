class Api::V1::SeoMetaSerializer < ActiveModel::Serializer
  attributes :id, :title, :keywords, :description

  def title
    object.browser_title
  end

  def keywords
    object.meta_keywords
  end

  def description
    object.meta_description
  end
end
