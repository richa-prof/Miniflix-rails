class FreeMember < ApplicationRecord

  # ASSOCIATIONS
  validates :email, uniqueness: true, presence: true, format: Devise.email_regexp

  def associated_user
    User.find_by_email(email)
  end

  def associated_user_id
    associated_user.try(:id)
  end
end
