require "rails_helper"

RSpec.describe DocumentsSyncJob, type: :job do
  let(:topic) { create(:topic, :with_documents) }
  let(:document) { topic.documents.first }
  let(:file_name) { [ topic.id, document.filename.to_s ] .join("_") }

  describe "#perform" do
    let(:file_worker) { instance_double(FileWorker) }

    before do
      allow(FileWorker).to receive(:new)
        .with(
          share: ENV["AZURE_STORAGE_SHARE_NAME"],
          name: file_name,
          path: "#{topic.language.file_storage_prefix}CMES-Pi/assets/Content",
          file: document.download,
          new_path: nil,
        ).and_return(file_worker)
      allow(FileWorker).to receive(:new)
        .with(
          share: ENV["AZURE_STORAGE_SHARE_NAME"],
          name: file_name,
          path: "#{topic.language.file_storage_prefix}CMES-v2/assets/Content",
          file: document.download,
          new_path: nil,
        ).and_return(file_worker)
    end

    context "when action is 'update'" do
      it "make FileWorker send the file" do
        expect(file_worker).to receive(:send).exactly(2).times

        described_class.perform_now(topic_id: topic.id, document_id: document.id, action: "update")
      end
    end

    context "when action is 'archive'" do
      before do
        topic.update(state: "archived")

        allow(FileWorker).to receive(:new)
          .with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: file_name,
            path: "#{topic.language.file_storage_prefix}CMES-Pi/assets/Content",
            file: document.download,
            new_path: "#{topic.language.file_storage_prefix}CMES-Pi_Archive",
          ).and_return(file_worker)
        allow(FileWorker).to receive(:new)
          .with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: file_name,
            path: "#{topic.language.file_storage_prefix}CMES-v2/assets/Content",
            file: document.download,
            new_path: "#{topic.language.file_storage_prefix}CMES-v2_Archive",
          ).and_return(file_worker)
      end

      it "makes FileWorker copy the file to archive and then delete it" do
        expect(file_worker).to receive(:copy).exactly(2).times
        expect(file_worker).to receive(:delete).exactly(2).times

        described_class.perform_now(topic_id: topic.id, document_id: document.id, action: "archive")
      end
    end

    context "when action is 'unarchive'" do
      before do
        allow(FileWorker).to receive(:new)
          .with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: file_name,
            path: "#{topic.language.file_storage_prefix}CMES-Pi_Archive",
            file: document.download,
            new_path: "#{topic.language.file_storage_prefix}CMES-Pi/assets/Content",
          ).and_return(file_worker)
        allow(FileWorker).to receive(:new)
          .with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: file_name,
            path: "#{topic.language.file_storage_prefix}CMES-v2_Archive",
            file: document.download,
            new_path: "#{topic.language.file_storage_prefix}CMES-v2/assets/Content",
          ).and_return(file_worker)
      end

      it "makes FileWorker copy the file back from archive and then delete it" do
        expect(file_worker).to receive(:copy).exactly(2).times
        expect(file_worker).to receive(:delete).exactly(2).times

        described_class.perform_now(topic_id: topic.id, document_id: document.id, action: "unarchive")
      end
    end

    context "when action is 'delete'" do
      it "makes FileWorker delete the file" do
        expect(file_worker).to receive(:delete).exactly(2).times

        described_class.perform_now(topic_id: topic.id, document_id: document.id, action: "delete")
      end
    end
  end
end
