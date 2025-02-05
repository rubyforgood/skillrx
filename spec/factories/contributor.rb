FactoryBot.define do
  factory :contributor do
    association :provider
    association :user
  end
end
