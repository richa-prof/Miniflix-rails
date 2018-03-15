module Api::V1::Concerns::UserSerializeDataConcern
  extend ActiveSupport::Concern

  def serialize_user
    ActiveModelSerializers::SerializableResource.new(@resource,
    each_serializer: Api::V1::UserSerializer)
  end

end
