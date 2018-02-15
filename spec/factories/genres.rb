FactoryBot.define do
  factory :genre do
    name Faker::Music.chord
    color Faker::Color.hex_color
  end
end
