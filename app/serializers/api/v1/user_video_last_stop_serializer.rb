class Api::V1::UserVideoLastStopSerializer < ActiveModel::Serializer
  attributes :last_stopped, :remaining_time

  def remaining_time
    object.remaining_time
  end
end
