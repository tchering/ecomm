FactoryBot.define do
  factory :category do
    title { Faker::Commerce.department }
    description { Faker::Lorem.paragraph }
    tax_rate { 13.0 }

    trait :with_image do
      after(:build) do |category|
        file_path = Rails.root.join("spec", "fixtures", "files", "test_image.jpg")
        category.image.attach(
          io: File.open(file_path),
          filename: "test_image.jpg",
          content_type: "image/jpeg",
        ) if File.exist?(file_path)
      end
    end
  end
end
