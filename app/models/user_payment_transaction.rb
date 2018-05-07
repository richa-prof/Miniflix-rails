class UserPaymentTransaction < ApplicationRecord
  belongs_to :user_payment_method

  #VALIDATION
  validates_uniqueness_of :transaction_id, allow_blank: true, allow_nil: true

  delegate :payment_type, to: :user_payment_method, prefix: :transcation,  allow_nil: true

  # ======= Related to mobile API's start =======
  def payment_type
    self.transcation_payment_type
  end

  def as_json(options=nil)
    super(except: [:created_at, :updated_at, :user_payment_method_id])
  end
  # ======= Related to mobile API's start =======
end
