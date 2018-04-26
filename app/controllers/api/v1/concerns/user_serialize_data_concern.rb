module Api::V1::Concerns::UserSerializeDataConcern
  extend ActiveSupport::Concern

  def serialize_user
    user = @resource || current_user
    ActiveModelSerializers::SerializableResource.new(user,
    each_serializer: Api::V1::UserSerializer)
  end

end
