class FreeMember < ApplicationRecord
  #Association
  validates :email, uniqueness: true, presence: true
end
