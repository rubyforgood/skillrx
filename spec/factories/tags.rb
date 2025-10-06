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
    sequence(:name) do |n|
      Faker::ProgrammingLanguage.name + n.to_s
    end

    trait :english do
      after(:build) do |tag|
        topic = create(:topic)
        topic.current_tags << tag
        topic.save
      end
    end
  end
end
