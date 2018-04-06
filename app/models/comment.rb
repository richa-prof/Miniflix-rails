class Comment < ApplicationRecord
  belongs_to :blog

  # Validations
  validates :body, presence: true

  def by_staff?
    user_id.present?
  end

  def commenter_user
    User.find(user_id)
  end
end
