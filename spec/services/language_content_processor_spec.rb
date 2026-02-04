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
    # 2 xml files for all providers, 1 xml file for single provider, 2 text files for tags, 5 csv files = 9
    # per provider 6 files (1 xml and 5 csv)
    files_number = language.providers.size * 6 + 9
    subject.perform

    expect(FileUploadJob).to have_received(:perform_later).exactly(files_number).times

    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "all_providers")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "all_providers_recent")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tags")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tags_and_title")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "files")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topics")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tag_details")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topic_tags")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topic_authors")
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "single_provider", provider.id)
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "files", provider.id)
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topics", provider.id)
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "tag_details", provider.id)
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topic_tags", provider.id)
    expect(FileUploadJob).to have_received(:perform_later).with(language.id, "topic_authors", provider.id)
  end
end
