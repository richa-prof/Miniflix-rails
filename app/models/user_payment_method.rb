class UserPaymentMethod < ApplicationRecord
  # TODO: Need to remove these attributes.
  attr_encrypted :card_number, key: ENV['credit_card_number_key']
  attr_encrypted :card_CVC , key: ENV['credit_card_cvc_key']
  attr_encrypted :expiration_month, :expiration_year, key: ENV['month_year_key']

  belongs_to :user
  has_many :user_payment_transactions, dependent: :destroy
  belongs_to :billing_plan

  #Enum start
  enum status:  {
                  active: 'Active',
                  inactive: 'Inactive'
                }
  enum payment_type: {
                        paypal: 'Paypal',
                        card: 'Card',
                        ios: 'ios'
                     }

  #Enum End

  validates_presence_of :payment_type
  # validates_presence_of :card_number, :expiration_month, :expiration_year, :card_CVC, if: 'Card?'
  validates :status, uniqueness: { scope: :user_id }, if: -> {active?}

  # CALLBACKS
  before_validation :deactive_user_payment_method, on: :create


  def service_period
    use_payment_expire_date  = created_at + 1.month
    "#{created_at.strftime('%m/%d/%y')}-#{use_payment_expire_date.strftime('%m/%d/%y')}"
  end

  def deactive_user_payment_method
    user = self.user
    user.user_payment_methods.update_all(status: UserPaymentMethod.statuses["inactive"])
    self.status = UserPaymentMethod.statuses["active"]
  end
end
