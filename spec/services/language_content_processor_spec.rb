require "rails_helper"

RSpec.describe LanguageContentProcessor do
  subject { described_class.new(language, share) }

  let(:language) { create(:language) }
  let(:provider) { create(:provider) }
  let(:share) { "skillrx-test" }
  let(:file_worker) { instance_double(FileWorker) }

  before do
    create(:topic, :tagged, :with_documents, language:, provider:)

    allow(FileUploadJob).to receive(:perform_later)
  end

  it "processes content for every language" do
    files_number = language.providers.size + 9 # 2 xml files for all provides, 2 text files for tags, 5 csv files
    subject.perform

    expect(FileUploadJob).to have_received(:perform_later).exactly(files_number).times

    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "all_providers", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "all_providers_recent", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tags", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tags_and_title", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "files", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topics", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tag_details", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topic_tags", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topic_authors", "file")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, provider.id, "provider")
  end
end
