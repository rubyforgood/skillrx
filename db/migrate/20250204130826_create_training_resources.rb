class CreateTrainingResources < ActiveRecord::Migration[8.0]
  def change
    create_table :training_resources do |t|
      t.integer :state

      t.timestamps
    end
  end
end
