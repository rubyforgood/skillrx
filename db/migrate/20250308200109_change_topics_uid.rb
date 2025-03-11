class ChangeTopicsUid < ActiveRecord::Migration[8.0]
  def up
    remove_column :topics, :uid
    add_column :topics, :uid, :string
  end

  def down
    remove_column :topics, :uid
    add_column :topics, :uid, :uuid, default: -> { "gen_random_uuid()" }, null: false
  end
end
