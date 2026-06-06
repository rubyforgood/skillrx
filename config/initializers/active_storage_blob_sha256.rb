Rails.application.config.to_prepare do
  ActiveStorage::Blob.include(ActiveStorageBlobSha256)
end
