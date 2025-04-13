class AddPublishedAtToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :published_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_index :topics, :published_at
  end
end
