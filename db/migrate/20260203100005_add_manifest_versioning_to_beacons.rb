class AddManifestVersioningToBeacons < ActiveRecord::Migration[8.0]
  def change
    add_column :beacons, :manifest_version, :integer, default: 0, null: false
    add_column :beacons, :manifest_checksum, :string
  end
end
