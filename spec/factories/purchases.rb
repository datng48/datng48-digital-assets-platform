FactoryBot.define do
  factory :purchase do
    amount { Faker::Commerce.price(range: 0..1000.0) }
    association :user, factory: :user
    association :asset
  end
end
