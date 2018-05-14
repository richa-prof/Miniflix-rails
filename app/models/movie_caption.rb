class MovieCaption < ApplicationRecord
  self.table_name = 'admin_movie_captions'

  attr_accessor :update_caption

  # ASSOCIATIONS
  belongs_to :movie, foreign_key: :admin_movie_id

  # UPLOADER
  mount_uploader :caption_file, MovieCaptionUploader

  # ENUMS
  LANGUAGE = ['English', 'French', 'German']

  # VALIDATIONS
  validates_format_of :caption_file, :with => %r{\.(srt|vtt|dfxp)}i
  validates_uniqueness_of :is_default, message: "Other movie is already set as default", scope: :admin_movie_id, if: :is_default
  validates_uniqueness_of :language, message: "selected language file already uploaded", scope: :admin_movie_id,  if: :update_caption
  validates_presence_of :language, if: :update_caption
  validates_presence_of :caption_file

  # SCOPE
  scope :active_caption, -> { where(status: true) }
  scope :default_caption, -> { where(is_default: true) }
end
