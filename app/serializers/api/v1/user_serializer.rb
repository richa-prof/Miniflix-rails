class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :registration_plan, :phone_number, :customer_id, :subscription_id, :cancelation_date, :receipt_data, :subscription_plan_status, :image, :sign_up_from, :cancelation_date, :payment_verified, :migrate_user

  def payment_verified
    object.is_payment_verified?
  end
end
