FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    role { :customer }

    trait :creator do
      role { :creator }
    end

    trait :admin do
      role { :admin }
    end
  end
end
