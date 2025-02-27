FactoryBot.define do
  factory :contact_inquiry do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    subject { Faker::Lorem.sentence }
    message { Faker::Lorem.paragraph }
    status { :pending }
    resolved_at { nil }
  end
end
