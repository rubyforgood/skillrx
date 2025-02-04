FactoryBot.define do
  factory :topic do
    association :provider
    association :language
    title { "topic" }
    description { "details" }
    uid { SecureRandom.uuid }
    state { 0 }

    trait :archived do
      state { 1 }
    end
  end
end
