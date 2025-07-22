# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  is_admin        :boolean          default(FALSE), not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    is_admin { false }

    after(:build) do |user|
      unless user.is_admin
        provider = create(:provider)
        user.providers << provider
      end
    end

    trait :admin do
      is_admin { true }
    end
  end
end
