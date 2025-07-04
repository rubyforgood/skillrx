require "rails_helper"

RSpec.describe DocumentsSyncJob, type: :job do
  let(:topic) { create(:topic, :with_documents) }
  let(:document) { topic.documents.first }

  describe "#perform" do
    let(:file_worker) { instance_double(FileWorker) }

    before do
      allow(FileWorker).to receive(:new)
        .with(
          share: ENV["AZURE_STORAGE_SHARE_NAME"],
          name: document.filename.to_s,
          path: "#{topic.language.file_storage_prefix}CMES-Pi/assets/content",
          file: document.download,
        ).and_return(file_worker)
    end

    context "when action is 'update'" do
      it "make FileWorker send the file" do
        expect(file_worker).to receive(:send)

        described_class.perform_now(topic.id, document.id, "update")
      end
    end

    context "when action is 'archive'" do
      it "makes FileWorker copy the file and then delete it" do
        expect(file_worker).to receive(:copy).with("#{topic.language.file_storage_prefix}CMES-Pi_Archive")
        expect(file_worker).to receive(:delete)

        described_class.perform_now(topic.id, document.id, "archive")
      end
    end

    context "when action is 'delete'" do
      it "makes FileWorker delete the file" do
        expect(file_worker).to receive(:delete)

        described_class.perform_now(topic.id, document.id, "delete")
      end
    end
  end
end
