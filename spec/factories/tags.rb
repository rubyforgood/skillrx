# == Schema Information
#
# Table name: tags
#
#  id             :bigint           not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :tag do
    name { Faker::ProgrammingLanguage.name }

    trait :english do
      after(:build) do |tag|
        topic = create(:topic)
        topic.set_tag_list_on(:en, name)
      end
    end
  end
end
