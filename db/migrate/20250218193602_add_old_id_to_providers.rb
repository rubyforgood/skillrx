class AddOldIdToProviders < ActiveRecord::Migration[8.0]
  def change
    add_column :providers, :old_id, :integer
    add_index :providers, :old_id, unique: true
  end
end
