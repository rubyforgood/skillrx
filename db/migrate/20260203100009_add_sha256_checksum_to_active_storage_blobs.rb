class AddSha256ChecksumToActiveStorageBlobs < ActiveRecord::Migration[8.0]
  def change
    add_column :active_storage_blobs, :sha256_checksum, :string
  end
end
