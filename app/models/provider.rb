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
class Provider < ApplicationRecord
  has_many :branches
  has_many :regions, through: :branches
  has_many :contributors
  has_many :users, through: :contributors
  has_many :topics

  validates :name, :provider_type, presence: true
  validates :name, uniqueness: true
end
