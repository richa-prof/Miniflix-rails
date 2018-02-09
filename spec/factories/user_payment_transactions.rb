FactoryBot.define do
  factory :user_payment_transaction do
    payment_date "2018-02-08 19:25:44 +0530"
    payment_expire_date "2018-03-08 19:25:44 +0530"
    amount 12
    transaction_id {Faker::Bank.iban}
  end
end
