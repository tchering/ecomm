FactoryBot.define do
  factory :order do
    association :user, factory: :customer_user
    sequence(:number) { |n| "ORD-#{100000 + n}" }
    email { user.email }
    total_amount { 99.99 }
    status { :pending }
    shipping_address { "123 Main St, Anytown, AN 12345" }
    billing_address { "123 Main St, Anytown, AN 12345" }
    payment_method { "credit_card" }

    trait :pending do
      status { :pending }
    end

    trait :processing do
      status { :processing }
    end

    trait :shipped do
      status { :shipped }
      shipped_at { Time.current }
    end

    trait :delivered do
      status { :delivered }
      shipped_at { 3.days.ago }
      delivered_at { Time.current }
    end

    trait :cancelled do
      status { :cancelled }
      cancelled_at { Time.current }
    end

    factory :pending_order, traits: [:pending]
    factory :processing_order, traits: [:processing]
    factory :shipped_order, traits: [:shipped]
    factory :delivered_order, traits: [:delivered]
    factory :cancelled_order, traits: [:cancelled]
  end
end
