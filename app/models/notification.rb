class Notification < ApplicationRecord
  belongs_to :admin_movie
  belongs_to :user
end
