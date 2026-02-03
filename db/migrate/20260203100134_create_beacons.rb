class CreateBeacons < ActiveRecord::Migration[8.1]
  def change
    create_table :beacons do |t|
      t.string :name
      t.string :location
      t.string :token
      t.datetime :last_seen_at
      t.boolean :online, default: false
      t.string :version
      t.bigint :language_id
      t.bigint :provider_id
      t.bigint :region_id

      t.timestamps
    end
    add_index :beacons, :token, unique: true
    add_index :beacons, :language_id
    add_index :beacons, :provider_id
    add_index :beacons, :region_id

    create_table :beacon_tags do |t|
      t.bigint :beacon_id
      t.bigint :tag_id

      t.timestamps
    end
    add_index :beacon_tags, :beacon_id
    add_index :beacon_tags, :tag_id
    add_index :beacon_tags, [:beacon_id, :tag_id], unique: true
  end
end
