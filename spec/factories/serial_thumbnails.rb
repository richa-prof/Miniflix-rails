FactoryBot.define do
  factory :serial_thumbnail do
    admin_serial { nil }
    serial_screenshot_1 { "MyString" }
    serial_screenshot_2 { "MyString" }
    serial_screenshot_3 { "MyString" }
    thumbnail_screenshot { "MyString" }
    thumbnail_640_screenshot { "MyString" }
    thumbnail_800_screenshot { "MyString" }
  end
end
