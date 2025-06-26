class ImportError < ApplicationRecord
  belongs_to :import_report

  validates :error_type, presence: true

  scope :by_type, ->(type) { where(error_type: type) }
  scope :with_files, -> { where.not(file_name: nil) }
end
