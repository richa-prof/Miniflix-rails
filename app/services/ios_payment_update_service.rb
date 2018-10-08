class IosPaymentUpdateService

  def initialize(user, mode=nil, extra_params={})
    @user = user
    @mode = mode
    @extra_params = extra_params
  end

  def call
    verify_receipt_url_and_build_payment_method(@user, @mode)
  end

  private

  def verify_receipt_url_and_build_payment_method(user, mode)
    itune_response = itune_request(user, mode)

    Rails.logger.debug "<<<<< verify_receipt_url_and_build_payment_method::itune_response : #{itune_response}  <<<< itune_response['status']:: #{itune_response['status']} <<<<<"

    response =
      if itune_response['status'] == 0
        latest_payment = fetch_latest_info(itune_response)

        check_and_save_payment_detail(user, latest_payment)
      else
        PAYMENT_LOGGER.debug "<<< IosPaymentUpdateService::verify_receipt_url_and_build_payment_method : user_id: #{user.id}, error: itune_response => #{itune_response['status']}, parameters: #{@extra_params} <<<"

        { success: false, error: I18n.t('flash.payment.receipt_data.error', status: itune_response['status']) }
      end
  end

  def itune_request(user, mode)
    target_uri = fetch_uri(mode)
    target_http_request = create_http_request(mode)

    Rails.logger.debug "<<<<< itune_request::user.receipt_data.blank? : #{user.receipt_data.blank?} <<<<<"

    response = target_http_request.post(target_uri.path, request_data(user), {'Content-Type' => 'application/x-www-form-urlencoded'})

    JSON.parse(response.body)
  end

  def create_http_request(mode)
    target_uri = fetch_uri(mode)

    Rails.logger.debug "<<<<< create_http_request::target_uri : #{target_uri} <<<<<"

    http = Net::HTTP.new(target_uri.host, target_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def fetch_uri(mode=nil)
    receipt_url = if mode == 'Production'
                    ENV['production_receipt_url']
                  elsif mode == 'Development'
                    ENV['development_receipt_url']
                  else
                    ENV['receipt_url']
                  end

    URI.parse(receipt_url)
  end

  def request_data(user)
    { 'receipt-data': user.receipt_data,
       password: ENV['iOS_password'],
       'exclude-old-transactions': true }.to_json
  end

  def fetch_latest_info(itune_response)
    itune_response['latest_receipt_info'].last
  end

  def check_and_save_payment_detail(user, latest_payment)
    assign_user_details(user, @extra_params)

    payment_method = user.latest_payment_method

    response =
      if payment_method.present?
        check_transaction_detail_and_build_payment_transaction(payment_method, latest_payment)
      else
        build_payment_method_and_transaction_detail(user, latest_payment)
      end
  end

  def check_transaction_detail_and_build_payment_transaction(user_payment_method, latest_payment)
    transaction = find_detail_by_transaction_id(latest_payment)
    response =
      if transaction.present?
        { success: true,
          transaction: transaction }
      else
        create_transaction_detail(user_payment_method, latest_payment)
      end
  end

  def find_detail_by_transaction_id(latest_payment)
    UserPaymentTransaction.find_by_transaction_id(latest_payment['transaction_id'])
  end

  def create_transaction_detail(user_payment_method, latest_payment)
    response =
      begin
        transaction = user_payment_method.user_payment_transactions.create!(user_payment_transaction_attributes(latest_payment))

        { success: true, transaction: transaction }
      rescue Exception => e
        PAYMENT_LOGGER.debug "<<< IosPaymentUpdateService::create_transaction_detail : user_payment_method: #{user_payment_method.inspect}, error: #{e.message}, parameters: #{user_payment_transaction_attributes(latest_payment)} <<<"

        { success: false, error: e.message }
      end
  end

  def build_payment_method_and_transaction_detail(user, latest_payment)
    response =
      payment_method = user.user_payment_methods.build(user_payment_method_nested_params(user, latest_payment))

      if payment_method.valid?
        { success: true,
          transaction: payment_method.user_payment_transactions.last }
      else
        error_message = payment_method.errors.full_messages[0]
        PAYMENT_LOGGER.debug "<<< IosPaymentUpdateService::build_payment_method_and_transaction_detail : user: #{user.inspect}, error: #{error_message}, parameters: #{user_payment_method_nested_params(user, latest_payment)} <<<"

        { success: false, error: error_message }
      end
  end

  def user_payment_method_nested_params(user, latest_payment)
    {
      payment_type:  UserPaymentMethod.payment_types['ios'],
      billing_plan: fetch_billing_plan(user),
      user_payment_transactions_attributes:{
        "0" => user_payment_transaction_attributes(latest_payment)
      }
    }
  end

  def user_payment_transaction_attributes(latest_payment)
    {
      payment_date:  convert_date_in_utc_format(latest_payment['purchase_date']),
      payment_expire_date: convert_date_in_utc_format(latest_payment['expires_date']),
      transaction_id: latest_payment['transaction_id'],
      amount: @extra_params['transaction_amount']
    }
  end

  def convert_date_in_utc_format(date)
    (Time.parse date).utc
  end

  def fetch_billing_plan(user)
    user.send(:fetch_billing_plan)
  end

  def assign_user_details(user, extra_params)
    subscription_plan_status = extra_params['subscription_plan_status']
    registration_plan = extra_params['registration_plan']

    if User.subscription_plan_statuses.values.include?(subscription_plan_status)
      user.subscription_plan_status = subscription_plan_status
    end

    if User.registration_plans.values.include?(registration_plan)
      user.registration_plan = registration_plan
    end
  end
end
