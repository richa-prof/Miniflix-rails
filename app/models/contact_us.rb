class ContactUs < ApplicationRecord

  # ASSOCIATIONS
  has_many :contact_user_replies, dependent: :destroy

  # ENUMS
  enum occupation: { professor: 'professor',
                     student: 'student' }

  # VALIDATIONS
  validates :email, uniqueness: true, format: Devise.email_regexp
  validates_presence_of :name, :school, :occupation, :email
  validates :occupation, inclusion: { in: occupations.keys }

  def associated_user
    User.find_by_email(email)
  end

  def associated_user_id
    associated_user.try(:id)
  end
end
