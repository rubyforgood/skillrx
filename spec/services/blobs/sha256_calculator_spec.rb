require "rails_helper"

RSpec.describe Blobs::Sha256Calculator do
  subject(:calculator) { described_class.new(blob) }

  let(:content) { "hello skillrx checksum world" }
  let(:expected_digest) { OpenSSL::Digest::SHA256.hexdigest(content) }
  let(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(content),
      filename: "sample.txt",
      content_type: "text/plain",
    )
  end

  before { blob.update_column(:sha256_checksum, nil) }

  describe "#call" do
    it "computes the SHA256 digest of the blob's content" do
      expect(calculator.call).to eq(expected_digest)
    end

    it "persists the digest on the blob" do
      calculator.call

      expect(blob.reload.sha256_checksum).to eq(expected_digest)
    end

    it "returns a 64-character lowercase hex string" do
      expect(calculator.call).to match(/\A[a-f0-9]{64}\z/)
    end

    it "overwrites any stale digest" do
      blob.update_column(:sha256_checksum, "stale")

      calculator.call

      expect(blob.reload.sha256_checksum).to eq(expected_digest)
    end
  end
end
