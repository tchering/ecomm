FactoryBot.define do
  factory :product do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    active { true }
    tax_rate { nil }
    association :category

    trait :with_images do
      after(:build) do |product|
        file_path = Rails.root.join("spec", "fixtures", "files", "test_image.jpg")
        if File.exist?(file_path)
          2.times do
            product.images.attach(
              io: File.open(file_path),
              filename: "test_image.jpg",
              content_type: "image/jpeg",
            )
          end
        end
      end
    end

    trait :inactive do
      active { false }
    end

    trait :with_tax_rate do
      tax_rate { 15.0 }
    end
  end
end
