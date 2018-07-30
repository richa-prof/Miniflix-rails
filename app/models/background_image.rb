class BackgroundImage < ApplicationRecord
  mount_uploader :image_file, BackgroundImageUploader

  # VALIDATIONS
  validates_presence_of :image_file

  def image_file_cloud_front_url
    target_path = image_file.try(:path)

    CommonHelpers.cloud_front_url(target_path)
  end
end
