require "rails_helper"

RSpec.describe FileUploadJob, type: :job do
  let(:language) { create(:language) }
  let(:processor) { LanguageContentProcessor.new(language) }

  describe "#perform" do
    before do
      allow(FileWorker).to receive(:new).and_return(instance_double(FileWorker, send: true))
    end

    context "when language specific file" do
      it "processes specific file" do
        processor.language_files.each do |file_id, file|
          expect(FileWorker).to receive(:new).with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: file.name,
            path: file.path,
            file: file.content[language],
          )

          described_class.perform_now(language.id, file_id.to_s)
        end
      end
    end

    context "when provider specific file" do
      let(:provider) { create(:provider, name: "Test Provider") }

      before { create(:topic, :tagged, language:, provider:) }

      it "processes specific file" do
        processor.provider_files.each do |file_id, file|
          expect(FileWorker).to receive(:new).with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: file.name[provider],
            path: file.path,
            file: file.content[provider],
          )

          described_class.perform_now(language.id, file_id.to_s, provider.id)
        end
      end

      context "when provider name contains /" do
        let(:provider) { create(:provider, name: "Test/Provider") }

        it "replaces / with - in the file name" do
          processor.provider_files.each do |file_id, file|
            expect(FileWorker).to receive(:new).with(
              share: ENV["AZURE_STORAGE_SHARE_NAME"],
              name: file.name[provider],
              path: file.path,
              file: file.content[provider],
            )

            described_class.perform_now(language.id, file_id.to_s, provider.id)
          end
        end
      end
    end
  end
end
