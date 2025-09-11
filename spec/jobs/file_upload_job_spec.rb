require "rails_helper"

RSpec.describe FileUploadJob, type: :job do
  # The only collaborator that should be stubbed is the one performing the
  # external action (the file upload). We want to test the full integration
  # with the real LanguageContentProcessor and its dependent generators.
  before do
    allow(FileWorker).to receive(:new).and_return(instance_double(FileWorker, send: true))
  end

  describe "#perform" do
    let!(:language) { create(:language) }

    context "when processing a language-specific file" do
      it "correctly looks up the file definition and generates the content" do
        # Create data to ensure the generator produces content.
        create(:topic, language: language)
        file_id = :all_providers_recent

        # Dynamically determine the expected output from the real objects.
        processor = LanguageContentProcessor.new(language)
        expected_file_definition = processor.language_files[file_id]
        expected_content = LanguageTopicsXmlGenerator.new(language, recent: true).perform

        expect(FileWorker).to receive(:new).with(
          share: ENV["AZURE_STORAGE_SHARE_NAME"],
          name: expected_file_definition.name,
          path: expected_file_definition.path,
          file: expected_content
        )

        described_class.perform_now(language.id, file_id.to_s, "file")
      end
    end

    context "when processing a provider-specific file" do
      # This single example replaces the three previous, repetitive tests.
      # It verifies that the job correctly handles provider name parameterization
      # by testing multiple cases in a data-driven way.
      it "generates the correct parameterized filename for various provider names" do
        test_cases = {
          "Test Provider" => "#{language.file_storage_prefix}test-provider.xml",
          "Test/Provider" => "#{language.file_storage_prefix}test-provider.xml",
          "WHO/Guidelines" => "#{language.file_storage_prefix}who-guidelines.xml",
        }

        test_cases.each do |provider_name, expected_filename|
          provider = create(:provider, name: provider_name)
          create(:topic, :tagged, language: language, provider: provider)

          expected_content = LanguageTopicsXmlGenerator.new(language, provider: provider).perform

          expect(FileWorker).to receive(:new).with(
            share: ENV["AZURE_STORAGE_SHARE_NAME"],
            name: expected_filename,
            path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
            file: expected_content
          )

          described_class.perform_now(language.id, provider.id, "provider")
        end
      end
    end
  end
end
