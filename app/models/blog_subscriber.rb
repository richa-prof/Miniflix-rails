class BlogSubscriber < ApplicationRecord

  validates :email, uniqueness: { message: 'is already subscribed!' }
  validates :email, format: { with: Devise.email_regexp,
                              message: 'is not valid!' }
end
