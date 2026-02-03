# == Schema Information
#
# Table name: languages
# Database name: primary
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
end
