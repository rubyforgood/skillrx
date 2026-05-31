class AddSyncStatusToBeacons < ActiveRecord::Migration[8.0]
  def change
    add_column :beacons, :sync_status, :string
    add_column :beacons, :last_seen_at, :datetime
    add_column :beacons, :last_sync_at, :datetime
    add_column :beacons, :reported_manifest_version, :string
    add_column :beacons, :reported_manifest_checksum, :string
    add_column :beacons, :reported_files_count, :integer
    add_column :beacons, :reported_total_size_bytes, :bigint
    add_column :beacons, :last_sync_error, :text
    add_column :beacons, :device_info, :jsonb

    add_index :beacons, :sync_status
    add_index :beacons, :last_seen_at
  end
end
