class Api::V1::MyActivitySerializer < ActiveModel::Serializer
  attributes :movie_name, :movie_title, :movie_slug, :last_updated, :remaining_time

  def last_updated
    object.updated_at.strftime("%A, %d %b %Y %l:%M %p")
  end

  def remaining_time
    object.remaining_time
  end
end
