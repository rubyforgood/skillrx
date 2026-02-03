# == Schema Information
#
# Table name: devices
# Database name: primary
#
#  id             :bigint           not null, primary key
#  api_key_digest :string           not null
#  api_key_prefix :string           not null
#  name           :string           not null
#  revoked_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :bigint           not null
#  region_id      :bigint           not null
#
# Indexes
#
#  index_devices_on_api_key_digest  (api_key_digest) UNIQUE
#  index_devices_on_language_id     (language_id)
#  index_devices_on_region_id       (region_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (region_id => regions.id)
#
FactoryBot.define do
  factory :device do
    sequence(:name) { |n| "Device #{n}" }
    association :language
    association :region
    api_key_digest { OpenSSL::Digest::SHA256.hexdigest(SecureRandom.hex(16)) }
    api_key_prefix { SecureRandom.hex(4) }

    trait :revoked do
      revoked_at { Time.current }
    end

    trait :with_providers do
      transient do
        provider_count { 2 }
      end

      after(:create) do |device, evaluator|
        create_list(:device_provider, evaluator.provider_count, device: device)
      end
    end

    trait :with_topics do
      transient do
        topic_count { 2 }
      end

      after(:create) do |device, evaluator|
        create_list(:device_topic, evaluator.topic_count, device: device)
      end
    end
  end
end
