require "rails_helper"

RSpec.describe LanguageContentProcessor do
  subject { described_class.new(language, share) }

  let(:language) { create(:language) }
  let(:provider) { create(:provider) }
  let(:share) { "skillrx-test" }
  let(:file_sender) { instance_double(FileSender) }

  before do
    create(:topic, :tagged, :with_documents, language:, provider:)

    allow(FileSender).to receive(:new).and_return(file_sender)
    allow(file_sender).to receive(:perform)
  end

  it "processes content for every language" do
    files_number = language.providers.size + 8 # 2 xml files for all provides, 2 xml files for tags, 4 csv files
    subject.perform

    expect(FileSender).to have_received(:new).with(
      share:,
      name: instance_of(String),
      path: instance_of(String),
      file: instance_of(String),
    ).exactly(files_number).times

    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}Server_XML.xml",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}New_Uploads_Server_XML.xml",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      name: "#{language.file_storage_prefix}tags.txt",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      name: "#{language.file_storage_prefix}tagsAndTitle.txt",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}#{provider.name}.xml",
      file: instance_of(String),
    )

    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      name: "#{language.file_storage_prefix}File.csv",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      name: "#{language.file_storage_prefix}Topic.csv",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      name: "#{language.file_storage_prefix}Tag.csv",
      file: instance_of(String),
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      name: "#{language.file_storage_prefix}TopicTag.csv",
      file: instance_of(String),
    )
    expect(file_sender).to have_received(:perform).exactly(files_number).times
  end
end
