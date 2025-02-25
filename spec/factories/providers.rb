# == Schema Information
#
# Table name: providers
#
#  id            :bigint           not null, primary key
#  name          :string
#  provider_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  old_id        :integer
#
# Indexes
#
#  index_providers_on_old_id  (old_id) UNIQUE
#
FactoryBot.define do
  factory :provider do
    sequence(:name) { |n| "provider_#{n}" }
    provider_type { "provider" }
  end
end
