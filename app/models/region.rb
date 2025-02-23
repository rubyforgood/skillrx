# == Schema Information
#
# Table name: regions
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Region < ApplicationRecord
  has_many :branches, dependent: :destroy
  has_many :providers, through: :branches

  validates :name, presence: true
end
