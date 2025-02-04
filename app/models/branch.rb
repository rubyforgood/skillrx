class Branch < ApplicationRecord
  has_many :providers
  has_many :regions
end