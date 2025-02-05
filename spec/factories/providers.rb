FactoryBot.define do
  factory :provider do
    name { "ACME" }
    provider_type { "provider" }

    trait :with_user do
      after(:create) do |provider|
        user = create(:user)
        provider.contributors.create(user: user)
      end
    end
  end
end
