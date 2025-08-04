require "rails_helper"

RSpec.describe FileManager do
  subject(:manager) { described_class.new(share:, action:, document:, topic:) }

  let(:share) { "skillrx-test" }
  let(:action) { "create" }
  let(:topic) { create(:topic) }
  let(:provider) { topic.provider }
  let(:document) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("spec", "fixtures", "files", "dummy.pdf")),
      filename: "dummy.pdf",
      content_type: "application/pdf",
    )
  end

  before { provider.update(file_name_prefix: "MyPrefix") }

  describe "#workers" do
    it "returns an array of file workers for the specified action" do
      workers = manager.workers

      expect(workers).to be_an(Array)
      expect(workers.size).to eq(2)
      expect(workers.first).to be_a(FileWorker)
    end

    it "initializes file workers with correct parameters" do
      expect(FileWorker).to receive(:new).with(
        share:,
        name: "#{topic.id}_myprefix_#{topic.published_at_year}_#{format('%02d', topic.published_at_month)}_dummy.pdf",
        path: "#{topic.language.file_storage_prefix}CMES-Pi/assets/Content",
        file: document.download,
        new_path: nil,
      ).and_call_original
      expect(FileWorker).to receive(:new).with(
        share:,
        name: "#{topic.id}_myprefix_#{topic.published_at_year}_#{format('%02d', topic.published_at_month)}_dummy.pdf",
        path: "#{topic.language.file_storage_prefix}CMES-v2/assets/Content",
        file: document.download,
        new_path: nil,
      ).and_call_original

      manager.workers
    end

    context "when names contain special characters" do
      let(:document) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "dummy.pdf")),
          filename: "file/with|special\\chars.pdf",
          content_type: "application/pdf",
        )
      end

      before { provider.update(file_name_prefix: "My/Prefix") }

      it "handles special characters in file names" do
        expect(FileWorker).to receive(:new).with(
          share:,
          name: "#{topic.id}_my-prefix_#{topic.published_at_year}_#{format('%02d', topic.published_at_month)}_file-with-special-chars.pdf",
          path: "#{topic.language.file_storage_prefix}CMES-Pi/assets/Content",
          file: document.download,
          new_path: nil,
        ).and_call_original
        expect(FileWorker).to receive(:new).with(
          share:,
          name: "#{topic.id}_my-prefix_#{topic.published_at_year}_#{format('%02d', topic.published_at_month)}_file-with-special-chars.pdf",
          path: "#{topic.language.file_storage_prefix}CMES-v2/assets/Content",
          file: document.download,
          new_path: nil,
        ).and_call_original

        manager.workers
      end
    end

    context "when video document" do
      let(:document) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "video_file_example.mp4")),
          filename: "video_file.mp4",
          content_type: "video/mp4",
        )
      end

      it "returns only one file worker" do
        workers = manager.workers

        expect(workers).to be_an(Array)
        expect(workers.size).to eq(1)
      end

      it "initializes file worker with parameters for video" do
        expect(FileWorker).to receive(:new).with(
          share:,
          name: "#{topic.id}_myprefix_#{topic.published_at_year}_#{format('%02d', topic.published_at_month)}_video_file.mp4",
          path: "#{topic.language.file_storage_prefix}CMES-v2/assets/VideoContent",
          file: document.download,
          new_path: nil,
        ).and_call_original

        manager.workers
      end
    end
  end
end
