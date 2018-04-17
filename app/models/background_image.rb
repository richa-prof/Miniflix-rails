class BackgroundImage < ApplicationRecord
  mount_uploader :image_file, BackgroundImageUploader

  # VALIDATIONS
  validates_presence_of :image_file
end
