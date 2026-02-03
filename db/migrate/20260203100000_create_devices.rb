class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string :name, null: false
      t.string :api_key_digest, null: false
      t.string :api_key_prefix, null: false
      t.references :language, null: false, foreign_key: true
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :devices, :api_key_digest, unique: true
  end
end
