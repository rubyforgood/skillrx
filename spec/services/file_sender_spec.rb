require "rails_helper"

RSpec.describe FileSender do
  subject(:sender) { described_class.new(share: "skillrx-test", file:, path:, name:) }

  let(:file) { "some_content" }
  let(:path) { "destination_path" }
  let(:name) { "destination_name" }

  let(:files) { instance_double("AzureFileShares::Operations::FileOperations") }

  before do
    allow(AzureFileShares).to receive_message_chain(:client, :files).and_return(files)
    allow(files).to receive(:directory_exists?).and_return(true)
    allow(files).to receive(:upload_file).with("skillrx-test", path, name, file)
  end

  it "sends a temporary file to destination" do
    expect(files).to receive(:upload_file).with("skillrx-test", path, name, file)

    sender.perform
  end
end
