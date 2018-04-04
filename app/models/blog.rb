class Blog < ApplicationRecord

  belongs_to :user
  has_many :comments, dependent: :destroy

  mount_uploader :featured_image, FeaturedImageUploader

  # Validations
  validates :title, :body, :featured_image, presence: true
  validates :title, length: { maximum: 60 }
end
