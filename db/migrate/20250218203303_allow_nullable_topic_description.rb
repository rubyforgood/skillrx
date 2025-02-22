class AllowNullableTopicDescription < ActiveRecord::Migration[8.0]
  def up
    change_column :topics, :description, :text, null: true
  end
  def down
    change_column :topics, :description, :text, null: false
  end
end
