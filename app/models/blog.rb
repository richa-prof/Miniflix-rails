class Blog < ApplicationRecord

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  mount_uploader :featured_image, FeaturedImageUploader

  # Validations
  validates :title, :body, presence: true
  validates :title, length: { maximum: 60 }

  def liked_by?(target_user)
    self.likes.where(user_id: target_user.id).any?
  end
end
