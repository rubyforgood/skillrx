class AddOldIdToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :old_id, :integer
    add_index :topics, :old_id, unique: true
  end
end
