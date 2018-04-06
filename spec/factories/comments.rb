FactoryBot.define do
  factory :comment do
    body "MyText"
    commenter "MyString"
    user_id 1
    blog nil
  end
end
