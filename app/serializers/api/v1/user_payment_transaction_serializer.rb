class Api::V1::UserPaymentTransactionSerializer < ActiveModel::Serializer
  attributes :transaction_id, :payment_date, :payment_expire_date, :payment_type, :amount

  def payment_expire_date
    object.payment_expire_date.strftime(" %A, %d %b %Y %l:%M %p")
  end

  def payment_date
    object.payment_expire_date.strftime(" %A, %d %b %Y %l:%M %p")
  end

  def amount
    (object.amount.present?) ? "$ #{object.amount}" : "$ 0.0"
  end

  def payment_type
    object.transcation_payment_type
  end
end
