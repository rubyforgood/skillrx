FactoryBot.define do
  factory :provider do
    sequence(:name) { |n| "provider_#{n}" }
    provider_type { "provider" }
  end
end
