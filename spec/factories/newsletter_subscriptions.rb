FactoryBot.define do
  factory :newsletter_subscription do
    sequence(:email) { |n| "subscriber#{n}@example.com" }
    name { "John Doe" }
    active { true }
    subscribed_at { Time.current }
    unsubscribed_at { nil }
  end
end
