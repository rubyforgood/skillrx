class DropTrainingResources < ActiveRecord::Migration[8.0]
  def change
    drop_table :training_resources
  end
end
