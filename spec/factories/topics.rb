# == Schema Information
#
# Table name: topics
#
#  id           :bigint           not null, primary key
#  description  :text
#  published_at :datetime         not null
#  state        :integer          default("active"), not null
#  title        :string           not null
#  uid          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  language_id  :bigint
#  old_id       :integer
#  provider_id  :bigint
#
# Indexes
#
#  index_topics_on_language_id   (language_id)
#  index_topics_on_old_id        (old_id) UNIQUE
#  index_topics_on_provider_id   (provider_id)
#  index_topics_on_published_at  (published_at)
#
FactoryBot.define do
  factory :topic do
    association :provider
    association :language
    title { "topic title" }
    description { "many topic details" }
    published_at { DateTime.new(2023, 1, 1) }
    state { 0 }

    trait :archived do
      state { 1 }
    end
  end
end
