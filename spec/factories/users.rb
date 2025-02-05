FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    is_admin { false }

    trait :admin do
      is_admin { true }
    end
  end
end
