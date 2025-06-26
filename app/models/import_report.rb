class ImportReport < ApplicationRecord
  has_many :import_errors, dependent: :destroy

  validates :import_type, presence: true

  enum :status, { pending: "pending", completed: "completed", failed: "failed" }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(import_type: type) }
end
