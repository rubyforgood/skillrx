class Region < ApplicationRecord
  has_many :branches, dependent: :destroy
  has_many :providers, through: :branches

  validates :name, presence: true
end
