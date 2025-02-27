FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :admin do
      admin { true }
    end

    trait :customer do
      admin { false }
    end

    factory :admin_user, traits: [:admin]
    factory :customer_user, traits: [:customer]
  end
end
