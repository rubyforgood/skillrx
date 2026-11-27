module Blobs
  class ComputeSha256ChecksumJob < ApplicationJob
    queue_as :default

    def perform(blob_id)
      blob = ActiveStorage::Blob.find_by(id: blob_id)
      return unless blob
      return if blob.sha256_checksum.present?

      Sha256Calculator.new(blob).call
    end
  end
end
