class BlogSubscriber < ApplicationRecord

  validates :email, uniqueness: { message: 'is already subscribed!' }
end
