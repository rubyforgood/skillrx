# == Schema Information
#
# Table name: topics
#
#  id          :bigint           not null, primary key
#  description :text             not null
#  state       :integer          default("active"), not null
#  title       :string           not null
#  uid         :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint
#  provider_id :bigint
#
# Indexes
#
#  index_topics_on_language_id  (language_id)
#  index_topics_on_provider_id  (provider_id)
#
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
