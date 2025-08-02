class AddTopicIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :topics, :created_at
  end
end
