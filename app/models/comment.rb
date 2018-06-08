class Comment < ApplicationRecord
  belongs_to :blog

  # Validations
  validates :body, presence: true
  validates :commenter, presence: true, if: -> { skip_commenter_validation }
  validates :commenter_email, presence: true, :format => Devise.email_regexp, if: -> { skip_commenter_validation }

  def by_staff?
    user_id.present?
  end

  def commenter_user
    User.find(user_id)
  end

  def skip_commenter_validation
    !by_staff?
  end
end
