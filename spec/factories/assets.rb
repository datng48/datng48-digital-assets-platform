FactoryBot.define do
  factory :asset do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    file_url { Faker::Internet.url }
    price { Faker::Commerce.price(range: 0..1000.0) }
    association :user, factory: [:user, :creator]
  end
end
