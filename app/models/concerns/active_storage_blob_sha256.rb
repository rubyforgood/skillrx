module ActiveStorageBlobSha256
  extend ActiveSupport::Concern

  included do
    after_create_commit :enqueue_sha256_checksum_calculation
  end

  # Returns the SHA256 digest of the blob's content, computing and
  # persisting it synchronously if it has not yet been calculated.
  def ensure_sha256_checksum
    return sha256_checksum if sha256_checksum.present?

    Blobs::Sha256Calculator.new(self).call
  end

  private

  def enqueue_sha256_checksum_calculation
    Blobs::ComputeSha256ChecksumJob.perform_later(id)
  end
end
