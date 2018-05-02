class UserPaymentTransaction < ApplicationRecord
  belongs_to :user_payment_method

  #VALIDATION
  validates_uniqueness_of :transaction_id, allow_blank: true, allow_nil: true

  delegate :payment_type, to: :user_payment_method, prefix: :transcation,  allow_nil: true
end
