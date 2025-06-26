# == Schema Information
#
# Table name: import_reports
#
#  id              :bigint           not null, primary key
#  completed_at    :datetime
#  error_details   :json
#  import_type     :string           not null
#  started_at      :datetime
#  status          :string           default("pending")
#  summary_stats   :json
#  unmatched_files :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_import_reports_on_import_type  (import_type)
#
class ImportReport < ApplicationRecord
  has_many :import_errors, dependent: :destroy

  validates :import_type, presence: true

  enum :status, { pending: "pending", planned: "planned", completed: "completed", failed: "failed" }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(import_type: type) }
end
