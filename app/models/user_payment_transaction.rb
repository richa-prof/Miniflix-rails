class UserPaymentTransaction < ApplicationRecord
  belongs_to :user_payment_method

  #VALIDATION
  validates_uniqueness_of :transaction_id, allow_blank: true, allow_nil: true

  delegate :payment_type, to: :user_payment_method, prefix: :transcation,  allow_nil: true

  # SCOPES
  scope :without_invalid_transaction_ids, -> { where.not(transaction_id: nil)  }

  # ===== Class methods Start =====
  class << self
    def total_income_of_current_month
      total_amount = without_invalid_transaction_ids.where('created_at >= ?', Time.now.beginning_of_month).sum(:amount)
    end

    def total_income_of_current_month_for_user(user)
      # FIXME add left join
      total_amount = without_invalid_transaction_ids.
        where('user_payment_transactions.created_at >= ?', Time.now.beginning_of_month).
        joins(:user_payment_method).where('user_payment_methods.user_id = ?', user.id).
        sum(:amount)
    end
  end
  # ===== Class methods End =====

  def payer_first_name
    user_payment_method.first_name
  end

  def payer_last_name
    user_payment_method.last_name
  end

  def service_period
    use_payment_expire_date = payment_expire_date.to_s(:full_date_abbr_month_and_year_format)
    use_payment_date = payment_date.to_s(:full_date_abbr_month_and_year_format)

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
