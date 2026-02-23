# == Schema Information
#
# Table name: regions
# Database name: primary
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :region do
    name { Faker::Address.state }
  end
end
