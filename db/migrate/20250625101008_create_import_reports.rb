class CreateImportReports < ActiveRecord::Migration[8.0]
  def change
    create_table :import_reports do |t|
      t.string :import_type, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.json :summary_stats
      t.json :unmatched_files
      t.json :error_details
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :import_reports, :import_type
  end
end
