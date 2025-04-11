# == Schema Information
#
# Table name: languages
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :language do
    name { Faker::Name.name }
  end

  # trait :tagged do
  #   after(:create) do |language|
  #     tag = build(:tag)
  #     provider = create(:provider)
  #     topic = build(:topic, provider:, language:)
  #     topic.set_tag_list_on(language.code.to_sym, tag.name)
  #     topic.save
  #   end
  # end
end
