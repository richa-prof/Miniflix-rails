FactoryBot.define do
  factory :user_payment_method do
    first_name {Faker::Name.name}
    last_name Faker::Name.first_name
    payment_type "paypal"
    association :user
    association :billing_plan
    # after(:build) { |payment_method|
    #   payment_method.user_payment_transactions << Factory.build(:user_payment_transaction, user_payment_method: payment_method)
    # }
    # after(:create) { |payment_method|
    #   payment_method.user_payment_transactions.each { |user_payment_transaction| user_payment_transaction.save! }
    # }
  end
end
