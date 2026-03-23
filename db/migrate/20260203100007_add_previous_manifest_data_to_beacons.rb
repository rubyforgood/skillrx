class AddPreviousManifestDataToBeacons < ActiveRecord::Migration[8.0]
  def change
    add_column :beacons, :previous_manifest_data, :jsonb
  end
end
