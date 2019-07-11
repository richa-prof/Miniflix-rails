class Organization < ApplicationRecord
  has_many :organizations_users_infos, dependent: :destroy
  has_many :users, through: :organizations_users_infos

  #validations
  validates_presence_of :org_name, :no_of_students

end
