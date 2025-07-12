class AddShadowCopyToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :shadow_copy, :boolean, default: false, null: false
  end
end
