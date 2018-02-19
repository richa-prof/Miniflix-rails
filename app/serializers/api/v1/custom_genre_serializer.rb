class Api::V1::CustomGenreSerializer < ActiveModel::Serializer
  attributes :total_page, :current_page, :genres

  def total_page
    object.total_pages
  end

  def current_page
    object.current_page
  end

  def genres
    ActiveModelSerializers::SerializableResource.new(object,
        each_serializer: Api::V1::GenreSerializer)
  end
end
