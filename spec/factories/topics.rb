FactoryBot.define do
  factory :topic do
    title { "Default Title" }
    description { "Default Description" }
    archived { false }
    association :language
    association :provider
  end
end
