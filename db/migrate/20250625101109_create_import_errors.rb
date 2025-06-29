class CreateImportErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :import_errors do |t|
      t.references :import_report, null: false, foreign_key: true
      t.string :error_type, null: false
      t.string :file_name
      t.integer :topic_id
      t.text :error_message
      t.json :metadata

      t.timestamps
    end

    add_index :import_errors, :error_type
    add_index :import_errors, :file_name
  end
end
