require "rails_helper"

RSpec.describe LanguageContentProcessor do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let(:provider) { create(:provider) }

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
      file: "temp_file_path",
      dest: instance_of(String)
    ).exactly(files_number).times

    expect(FileSender).to have_received(:new).with(
      file: "temp_file_path",
      dest: "#{language.file_storage_prefix}_all_providers.xml"
    )
    expect(FileSender).to have_received(:new).with(
      file: "temp_file_path",
      dest: "#{language.file_storage_prefix}_all_providers_recent.xml"
    )
    expect(FileSender).to have_received(:new).with(
      file: "temp_file_path",
      dest: "#{language.file_storage_prefix}_tags.txt"
    )
    expect(FileSender).to have_received(:new).with(
      file: "temp_file_path",
      dest: "#{language.file_storage_prefix}_title_and_tags.txt"
    )
    expect(FileSender).to have_received(:new).with(
      file: "temp_file_path",
      dest: "#{language.file_storage_prefix}_#{provider.name}.xml"
    )
    expect(FileSender).to have_received(:new).with(
      file: "temp_file_path",
      dest: "#{language.file_storage_prefix}_#{provider.name}_recent.xml"
    )
    expect(file_sender).to have_received(:perform).exactly(files_number).times
  end
end
