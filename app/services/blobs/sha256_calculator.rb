module Blobs
  class Sha256Calculator
    def initialize(blob)
      @blob = blob
    end

    def call
      digest = compute_digest
      blob.update_column(:sha256_checksum, digest)
      digest
    end

    private

    attr_reader :blob

    def compute_digest
      sha = OpenSSL::Digest::SHA256.new
      blob.download { |chunk| sha.update(chunk) }
      sha.hexdigest
    end
  end
end
