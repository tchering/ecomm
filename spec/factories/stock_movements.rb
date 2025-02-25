FactoryBot.define do
  factory :stock_movement do
    product { nil }
    warehouse { nil }
    quantity { 1 }
    movement_type { "MyString" }
    notes { "MyText" }
    user { nil }
  end
end
