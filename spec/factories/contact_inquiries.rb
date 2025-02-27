FactoryBot.define do
  factory :contact_inquiry do
    name { "Jane Doe" }
    sequence(:email) { |n| "inquirer#{n}@example.com" }
    sequence(:subject) { |n| "Inquiry Subject #{n}" }
    message { "This is a test inquiry message. Please respond when you can." }
    status { :new }
    resolved_at { nil }
  end
end
