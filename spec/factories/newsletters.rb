FactoryBot.define do
  factory :newsletter do
    sequence(:subject) { |n| "Newsletter Subject #{n}" }
    content { "This is the content of the newsletter. It includes important updates and announcements." }
    sent_at { Time.current }
  end
end
