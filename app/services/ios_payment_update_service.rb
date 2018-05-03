class IosPaymentUpdateService

  def initialize(user)
    @user = user
  end

  def call
    verify_receipt_url_and_build_payment_method(@user)
  end

  private

  def verify_receipt_url_and_build_payment_method(user)
    itune_response = itune_request(user)
    if itune_response['status'] == 0
      latest_payment = fetch_latest_info(itune_response)
      check_and_save_payment_detail(user, latest_payment)
    else
      false
    end
  end

  def itune_request(user)
    response = create_http_request.post(fetch_uri.path, request_data(user), {'Content-Type' => 'application/x-www-form-urlencoded'})
    JSON.parse(response.body)
  end

  def create_http_request
    http = Net::HTTP.new(fetch_uri.host, fetch_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def fetch_uri
    URI.parse(ENV['receipt_url'])
  end

  def request_data(user)
    {'receipt-data': user.receipt_data,password: ENV['iOS_password'], 'exclude-old-transactions': true }.to_json
  end

  def fetch_latest_info(itune_response)
    itune_response['latest_receipt_info'].last
  end

  def check_and_save_payment_detail(user, latest_payment)
    user_payment_method = user.user_payment_methods.last
    if user_payment_method.present?
      check_transaction_detail_and_build_payment_transaction(user_payment_method, latest_payment)
    else
      build_payment_method_and_transaction_detail(user, latest_payment)
    end
  end

  def check_transaction_detail_and_build_payment_transaction(user_payment_method, latest_payment)
    if find_detail_by_transaction_id(latest_payment)
      true
    else
      create_transaction_detail(user_payment_method, latest_payment)
    end
  end

  def find_detail_by_transaction_id(latest_payment)
    UserPaymentTransaction.find_by_transaction_id(latest_payment['transaction_id'])
  end

  def create_transaction_detail(user_payment_method, latest_payment)
    begin
      user_payment_method.user_payment_transactions.create!(user_payment_transaction_attributes(latest_payment))
    rescue Exception => e
      false
    end
  end

  def build_payment_method_and_transaction_detail(user, latest_payment)
    user.user_payment_methods.build(user_payment_method_nested_params(latest_payment))
  end

  def user_payment_method_nested_params(latest_payment)
    {
      payment_type:  UserPaymentMethod.payment_types['iOS'],
      user_payment_transactions_attributes:{
        "0" => user_payment_transaction_attributes(latest_payment)
      }
    }
  end

  def user_payment_transaction_attributes(latest_payment)
    {
      payment_date:  convert_date_in_utc_format(latest_payment['purchase_date']),
      payment_expire_date: convert_date_in_utc_format(latest_payment['expires_date']),
      transaction_id: latest_payment['transaction_id']
    }
  end

  def convert_date_in_utc_format(date)
    (Time.parse date).utc
  end
end
