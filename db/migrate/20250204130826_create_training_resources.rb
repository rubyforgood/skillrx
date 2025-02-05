class CreateTrainingResources < ActiveRecord::Migration[8.0]
  def change
    create_table :training_resources do |t|
      t.integer :state
      t.string :file_name_override
      t.references :topic

      t.timestamps
    end
  end
end
