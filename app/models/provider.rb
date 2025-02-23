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
class Provider < ApplicationRecord
  has_many :branches
  has_many :regions, through: :branches
  has_many :contributors
  has_many :users, through: :contributors

  validates :name, :provider_type, presence: true
  validates :name, uniqueness: true
end
