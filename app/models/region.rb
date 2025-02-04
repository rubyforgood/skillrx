class Region < ApplicationRecord
  has_many :branches
  has_many :providers, through: :branches

  validates :name, presence: true
end
