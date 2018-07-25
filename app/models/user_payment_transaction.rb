class UserPaymentTransaction < ApplicationRecord
  belongs_to :user_payment_method

  #VALIDATION
  validates_uniqueness_of :transaction_id, allow_blank: true, allow_nil: true

  delegate :payment_type, to: :user_payment_method, prefix: :transcation,  allow_nil: true

  def payer_first_name
    user_payment_method.first_name
  end

  def payer_last_name
    user_payment_method.last_name
  end

  def service_period
    use_payment_expire_date = payment_expire_date.to_s(:month_date_year_slash_separated_format)
    use_payment_date = payment_date.to_s(:month_date_year_slash_separated_format)

    "#{use_payment_date} - #{use_payment_expire_date}"
  end

  # ======= Related to mobile API's start =======
  def payment_type
    self.transcation_payment_type
  end

  def as_json(options=nil)
    result = super

    return result if result.has_key?("payer_first_name")

    super(except: [:created_at, :updated_at, :user_payment_method_id])
  end
  # ======= Related to mobile API's start =======
end
