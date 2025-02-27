FactoryBot.define do
  factory :contact_response do
    association :contact_inquiry
    message { "Thank you for your inquiry. We appreciate your feedback and will address your concerns promptly." }
    sent_at { Time.current }
  end
end
