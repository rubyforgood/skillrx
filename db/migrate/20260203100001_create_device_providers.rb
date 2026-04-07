class CreateDeviceProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :device_providers do |t|
      t.references :device, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end

    add_index :device_providers, [ :device_id, :provider_id ], unique: true
  end
end
