class UserPaymentMethod < ApplicationRecord
  # attr_encrypted :card_number, key: ENV['credit_card_number_key']
  # attr_encrypted :card_CVC , key: ENV['credit_card_cvc_key']
  # attr_encrypted :expiration_month, :expiration_year, key: ENV['month_year_key']

  belongs_to :user
  has_many :user_payment_transactions, dependent: :destroy
  enum payment_type: {Paypal: 'Paypal', Card: 'Card', iOS: 'ios'}

  validates_presence_of :payment_type
  validates_presence_of :card_number, :expiration_month, :expiration_year, :card_CVC, if: 'Card?'


  accepts_nested_attributes_for :user_payment_transactions, reject_if: lambda { |a| a[:payment_expire_date].blank? }, allow_destroy: true

  def service_period
    use_payment_expire_date  = created_at + 1.month

    "#{created_at.strftime('%m/%d/%y')}-#{use_payment_expire_date.strftime('%m/%d/%y')}"
  end
end
