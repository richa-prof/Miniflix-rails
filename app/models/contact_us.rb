class ContactUs < ApplicationRecord

  # ASSOCIATIONS
  has_many :contact_user_replies, dependent: :destroy

  # ENUMS
  enum occupation: { Professor: 'Professor',
                     Student: 'Student' }

  # VALIDATIONS
  validates :email, uniqueness: true, format: Devise.email_regexp
  validates_presence_of :name, :school, :occupation, :email
  validates :occupation, inclusion: { in: occupations.keys }

end
