# == Schema Information
#
# Table name: providers
#
#  id            :bigint           not null, primary key
#  name          :string
#  provider_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :provider do
    sequence(:name) { |n| "provider_#{n}" }
    provider_type { "provider" }
  end
end
