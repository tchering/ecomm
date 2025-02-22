FactoryBot.define do
  factory :address do
    street_address { "MyString" }
    apartment { "MyString" }
    city { "MyString" }
    state { "MyString" }
    postal_code { "MyString" }
    country { "MyString" }
    user { nil }
    is_default { false }
  end
end
