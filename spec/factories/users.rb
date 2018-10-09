FactoryBot.define do
  factory :user do |f|
    f.name {Faker::Name.name}
    f.email {Faker::Internet.email}
    f.password "123456789"
    f.registration_plan 'Monthly'
    f.sign_up_from 'Web'
  end
end
