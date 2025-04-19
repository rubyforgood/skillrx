require "rails_helper"

RSpec.describe FileWriter do
  subject(:writer) { described_class.new(file) }

  let(:file) { FileToUpload.new(id: 1, name: "file_name", content: "file_content", path: "path") }
  let(:temp_file) { double("Tempfile") }

  before do
    allow(Tempfile).to receive(:new).and_return(temp_file)
    allow(temp_file).to receive(:write)
  end

  it "creates a temporary file" do
    expect(Tempfile).to receive(:new).with(file.name)
    expect(temp_file).to receive(:write).with(file.content)
    expect(temp_file).to receive(:close)
    expect(temp_file).to receive(:unlink)
    expect(temp_file).to receive(:rewind)

    writer.temporary_file { }
  end
end
