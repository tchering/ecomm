FactoryBot.define do
  factory :cart do
    trait :with_items do
      after(:create) do |cart|
        create_list(:cart_item, 3, cart: cart)
      end
    end
  end
end
