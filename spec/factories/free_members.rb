FactoryBot.define do
  factory :free_member do
    email {Faker::Internet.email}
  end
end
