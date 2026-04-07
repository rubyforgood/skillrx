class RenameDevicesToBeacons < ActiveRecord::Migration[8.0]
  def change
    rename_table :devices, :beacons
    rename_table :device_providers, :beacon_providers
    rename_table :device_topics, :beacon_topics

    rename_column :beacon_providers, :device_id, :beacon_id
    rename_column :beacon_topics, :device_id, :beacon_id
  end
end
