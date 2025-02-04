class Provider < ApplicationRecord
  has_many :branches
  has_many :regions, through: :branches

  validates :name, :provider_type, presence: true
end
