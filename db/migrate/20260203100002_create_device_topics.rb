class CreateDeviceTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :device_topics do |t|
      t.references :device, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end

    add_index :device_topics, [ :device_id, :topic_id ], unique: true
  end
end
