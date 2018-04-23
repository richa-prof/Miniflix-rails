class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :registration_plan, :phone_number, :customer_id, :subscription_id, :cancelation_date, :receipt_data, :subscription_plan_status, :image, :sign_up_from, :cancelation_date, :payment_verified, :migrate_user, :valid_for_thankyou_page, :current_payment_method

  def payment_verified
    object.is_payment_verified?
  end

  def current_payment_method
    user_payment_methods = object.user_payment_methods
    user_payment_methods.active.last.payment_type if user_payment_methods.present?
  end
end
