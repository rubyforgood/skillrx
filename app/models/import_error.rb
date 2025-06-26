# == Schema Information
#
# Table name: import_errors
#
#  id               :bigint           not null, primary key
#  error_message    :text
#  error_type       :string           not null
#  file_name        :string
#  metadata         :json
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  import_report_id :bigint           not null
#  topic_id         :integer
#
# Indexes
#
#  index_import_errors_on_error_type        (error_type)
#  index_import_errors_on_file_name         (file_name)
#  index_import_errors_on_import_report_id  (import_report_id)
#
# Foreign Keys
#
#  fk_rails_...  (import_report_id => import_reports.id)
#
class ImportError < ApplicationRecord
  belongs_to :import_report

  validates :error_type, presence: true

  scope :by_type, ->(type) { where(error_type: type) }
  scope :with_files, -> { where.not(file_name: nil) }
end
