class AddManifestDataToBeacons < ActiveRecord::Migration[8.0]
  def change
    add_column :beacons, :manifest_data, :jsonb
  end
end
