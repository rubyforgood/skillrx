FactoryBot.define do
  factory :tag, class: ActsAsTaggableOn::Tag do
    name { Faker::ProgrammingLanguage.name }

    trait :english do
      after(:build) do |tag|
        topic = create(:topic)
        topic.set_tag_list_on(:en, name)
      end
    end
  end
end
