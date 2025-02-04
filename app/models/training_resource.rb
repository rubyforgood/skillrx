class TrainingResource < ApplicationRecord
  has_one_attached :document
  validates :state, presence: true
end
