class TrainingResource < ApplicationRecord
  belongs_to :topic
  has_one :language, through: :topic
  has_one_attached :document

  validates :state, presence: true

  validates_with DocumentValidator
  validates_with ResourceLanguageValidator
end
