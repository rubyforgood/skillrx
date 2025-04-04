FactoryBot.define do
  factory :tag_cognate do
    association :tag
    association :cognate, factory: :tag
  end
end
