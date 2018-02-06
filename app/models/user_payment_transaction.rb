class UserPaymentTransaction < ApplicationRecord
  belongs_to :user_payment_method
end
