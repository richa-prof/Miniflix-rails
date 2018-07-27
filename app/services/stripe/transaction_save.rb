class Stripe::TransactionSave
  def initialize(user, webhook_params)
    @user = user
    @invoice_detail = webhook_params[:data][:object]
  end

  def call
    parse_webhook_params_and_save_transaction_detail(@user, @invoice_detail)
  end

  private

  def parse_webhook_params_and_save_transaction_detail(user, invoice_detail)
    begin
      unless check_transaction_detail_present_or_not(user, invoice_detail)
        create_transaction_detail_and_update_subscription_status(user, invoice_detail)
        { sucess: true, message: I18n.t('flash.payment_transaction.successfully_saved') }
      else
        { sucess: true, message: I18n.t('flash.payment_transaction.already_present') }
      end
    rescue Exception => e
      { sucess: false, message: e.message }
    end
  end

  def create_transaction_detail_and_update_subscription_status(user, invoice_detail)
    payment_method = user.latest_payment_method
    payment_method.user_payment_transactions.create(transaction_detail_attribute(invoice_detail))
    user.activate!
  end

  def check_transaction_detail_present_or_not(user, invoice_detail)
    user.my_transactions.find_by(transaction_id: invoice_detail[:id])
  end

  def transaction_detail_attribute(invoice_detail)
    {
      payment_date: get_payment_date(invoice_detail),
      payment_expire_date: get_payment_expire_date(invoice_detail),
      transaction_id: invoice_detail[:id],
      amount: paid_amount(invoice_detail)
    }
  end

  def paid_amount(invoice_detail)
    amount = invoice_detail[:amount_paid]
    (amount/100.0)
  end

  def get_payment_date(invoice_detail)
    integer_date = invoice_time_limit(invoice_detail)[:start]
    Time.at(integer_date).to_datetime
  end

  def get_payment_expire_date(invoice_detail)
    integer_date = invoice_time_limit(invoice_detail)[:end]
    Time.at(integer_date).to_datetime
  end

  def invoice_time_limit(invoice_detail)
    invoice_detail[:lines][:data].first[:period]
  end

  def calculate_amount(total_amount)
    (total_amount/100.0)
  end
end
