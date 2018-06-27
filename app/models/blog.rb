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

  def featured_image_large_url
    target_path = featured_image.large.try(:path)

    featured_image_cloud_front_url(target_path)
  end

  def featured_image_medium_url
    target_path = featured_image.medium.try(:path)

    featured_image_cloud_front_url(target_path)
  end

  def featured_image_default_url
    "#{ENV['RAILS_HOST']}/#{featured_image.default_url}"
  end

  private

  def featured_image_cloud_front_url(target_path)
    if target_path.present?
      return CommonHelpers.cloud_front_url(target_path)
    end

    featured_image_default_url
  end

end
