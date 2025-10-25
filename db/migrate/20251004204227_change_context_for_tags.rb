class ChangeContextForTags < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE taggings SET context = 'tags'"
  end

  def down
  end
end
