require "rails_helper"

RSpec.describe ActiveStorageBlobSha256 do
  let(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("concern content"),
      filename: "concern.txt",
      content_type: "text/plain",
    )
  end

  describe "#ensure_sha256_checksum" do
    context "when the checksum is already stored" do
      before { blob.update_column(:sha256_checksum, "cached-digest") }

      it "returns the stored value without recomputing" do
        allow(Blobs::Sha256Calculator).to receive(:new)

        expect(blob.ensure_sha256_checksum).to eq("cached-digest")
        expect(Blobs::Sha256Calculator).not_to have_received(:new)
      end
    end

    context "when the checksum is missing" do
      before { blob.update_column(:sha256_checksum, nil) }

      it "computes, stores, and returns the SHA256 digest" do
        digest = blob.ensure_sha256_checksum

        expect(digest).to match(/\A[a-f0-9]{64}\z/)
        expect(blob.reload.sha256_checksum).to eq(digest)
      end
    end
  end
end
