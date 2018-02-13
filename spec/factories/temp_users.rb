FactoryBot.define do
  factory :temp_user do
    registration_plan  User.registration_plans.keys
    email {Faker::Internet.email}
    name {Faker::Name.name}
  end
end
