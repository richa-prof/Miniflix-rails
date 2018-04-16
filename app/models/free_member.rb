class FreeMember < ApplicationRecord

  # ASSOCIATIONS
  validates :email, uniqueness: true, presence: true
end
