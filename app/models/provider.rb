class Provider < ApplicationRecord
  has_many :branches
  has_many :regions, through: :branches
  has_many :contributors
  has_many :users, through: :contributors

  validates :name, :provider_type, presence: true
  validates :name, uniqueness: true
end
