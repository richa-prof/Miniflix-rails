class PaypalTransactionService
  PaypalTimeZone = "Pacific Time (US & Canada)"

  def initialize(user ,response)
    @user = user
    @response = response
  end

  def call
    make_entry_for_transaction_detail(@user ,@response)
  end

  private

  def make_entry_for_transaction_detail(user, response)
    transaction_detail = user.my_transactions.find_by(transaction_id: response[:txn_id])
    create_and_update_transaction_detail(user, transaction_detail, response)
    change_subscriptions_status(user)
  end

  def create_and_update_transaction_detail(user, transaction_detail, response)
    transaction_detail.update_attributes(transaction_detail_attribute(user, transaction_detail, response))
  end

  def transaction_detail_attribute(user, transaction_detail, response)
    attributes =
    {
      payment_date: paypal_payment_date(response),
      payment_expire_date: paypal_payment_expire_date(response),
      amount: response[:mc_gross],
      transaction_id: response[:txn_id]
    }
    attributes.merge!(user_payment_method: fetch_user_payment_method(user)) if transaction_detail.new_record?
    attributes
  end

  def fetch_user_payment_method(user)
    user.find_user_payment_method
  end

  def paypal_payment_date(response)
    payment_date =  response[:payment_date]
    convert_date_to_ugc_format(payment_date)
  end

  def paypal_payment_expire_date(response)
    payment_date =  response[:next_payment_date]
    convert_date_to_ugc_format(payment_date)
  end

  def convert_date_to_ugc_format(date)
    pdt_datetime = ActiveSupport::TimeZone[PaypalTimeZone].parse(date)
    pdt_datetime.in_time_zone('UTC')
  end

  def change_subscriptions_status(user)
    user.activate!
  end
end
