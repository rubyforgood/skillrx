require "rails_helper"

RSpec.describe Blobs::ComputeSha256ChecksumJob, type: :job do
  describe "#perform" do
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("job test content"),
        filename: "job.txt",
        content_type: "text/plain",
      )
    end
    let(:calculator) { instance_double(Blobs::Sha256Calculator, call: "digest") }

    before do
      allow(Blobs::Sha256Calculator).to receive(:new).and_return(calculator)
      blob.update_column(:sha256_checksum, nil)
    end

    it "delegates calculation to Blobs::Sha256Calculator" do
      described_class.perform_now(blob.id)

      expect(Blobs::Sha256Calculator).to have_received(:new).with(blob)
      expect(calculator).to have_received(:call)
    end

    context "when the blob does not exist" do
      it "returns without invoking the calculator" do
        described_class.perform_now(-1)

        expect(Blobs::Sha256Calculator).not_to have_received(:new)
      end
    end

    context "when the blob already has a checksum" do
      before { blob.update_column(:sha256_checksum, "already-there") }

      it "skips calculation" do
        described_class.perform_now(blob.id)

        expect(Blobs::Sha256Calculator).not_to have_received(:new)
      end
    end
  end
end
