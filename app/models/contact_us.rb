class ContactUs < ApplicationRecord

  #Association
  has_many :contact_user_replies

  #enum
  enum occupation: {Professor: 'Professor', Student: 'Student'}

  #Validation
  validates :email, uniqueness: true, format: Devise.email_regexp
  validates_presence_of :name, :school, :occupation, :email
  validates :occupation, inclusion: { in: occupations.keys }

end
