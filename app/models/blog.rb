class Blog < ApplicationRecord

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  mount_uploader :featured_image, FeaturedImageUploader

  # Ref.: https://github.com/norman/friendly_id
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Validations
  validates :title, :body, :description, presence: true
  validates :title, length: { maximum: 105 }
  validates :description, length: { maximum: 200 }

  # Scopes
  scope :with_search_query, -> (q) { where('title LIKE ? or body LIKE ? ', "%#{q}%", "%#{q}%") if q.present? }

  def liked_by?(target_user)
    return false unless target_user

    self.likes.where(user_id: target_user.id).any?
  end
end
