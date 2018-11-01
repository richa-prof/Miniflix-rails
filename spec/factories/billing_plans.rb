FactoryBot.define do
  factory :billing_plan do
    name "MyString"
    description "MyString"
    amount 1
    currency "USD"
    interval "Month"
    trial_days 1
  end
end
