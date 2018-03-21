class MovieCaption < ApplicationRecord
  self.table_name = "admin_movie_captions"

  attr_accessor :update_caption
  #Association
  belongs_to :movie, foreign_key: :admin_movie_id

  #uploader
  mount_uploader :caption_file, MovieCaptionUploader

  #enum
  LANGUAGE = ['English', 'French', 'German']

  #validation
  validates_format_of :caption_file, :with => %r{\.(srt|vtt|dfxp)}i
  validates_uniqueness_of :is_default, message: "Other movie is already set as default", scope: :admin_movie_id, if: :is_default
  validates_uniqueness_of :language, message: "selected language file already uploaded", scope: :admin_movie_id,  if: :update_caption
  validates_presence_of :language, if: :update_caption
  validates_presence_of :caption_file

  #scope
  scope :active_caption, -> { where(status: true) }
  scope :default_caption, -> { where(is_default: true) }
end
