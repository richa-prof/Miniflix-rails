class Api::V1::MovieCaptionSerializer < ActiveModel::Serializer
  attributes  :language, :caption_file, :is_default

  def caption_file
    object.caption_file_cloudfront_url
  end
end
