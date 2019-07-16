class OrganizationsUsersInfo < ApplicationRecord
  #Associations
  belongs_to :user
  belongs_to :organization

  enum role: [:admin, :student]

  # SCOPES
  scope :admin, -> {where(role: 'admin').take}
  scope :student, -> {where(role: 'student').take}
end
