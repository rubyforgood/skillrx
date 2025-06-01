require "rails_helper"

RSpec.describe LanguageContentProcessor do
  subject { described_class.new(language, share) }

  let(:language) { create(:language) }
  let(:provider) { create(:provider) }
  let(:share) { "skillrx-test" }

  let(:file_writer) { instance_double(FileWriter) }
  let(:file_sender) { instance_double(FileSender) }

  before do
    create(:topic, :tagged, :with_documents, language:, provider:)

    allow(FileWriter).to receive(:new).and_return(file_writer)
    allow(file_writer).to receive(:temporary_file).and_yield("temp_file_path")
    allow(FileSender).to receive(:new).and_return(file_sender)
    allow(file_sender).to receive(:perform)
  end

  it "content for every language" do
    files_number = (language.providers.size + 1) * 2 + 2
    subject.perform

    expect(FileWriter).to have_received(:new).with(instance_of(FileToUpload)).exactly(files_number).times
    expect(file_writer).to have_received(:temporary_file).exactly(files_number).times
    expect(FileSender).to have_received(:new).with(
      share:,
      name: instance_of(String),
      path: instance_of(String),
      file: "temp_file_path",
    ).exactly(files_number).times

    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}Server_XML.xml",
      file: "temp_file_path",
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}New_Uploads_Server_XML.xml",
      file: "temp_file_path",
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      name: "#{language.file_storage_prefix}tags.txt",
      file: "temp_file_path",
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      name: "#{language.file_storage_prefix}tagsAndTitle.txt",
      file: "temp_file_path",
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}#{provider.name}.xml",
      file: "temp_file_path",
    )
    expect(FileSender).to have_received(:new).with(
      share:,
      path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      name: "#{language.file_storage_prefix}New_Uploads_#{provider.name}.xml",
      file: "temp_file_path",
    )
    expect(file_sender).to have_received(:perform).exactly(files_number).times
  end
end
