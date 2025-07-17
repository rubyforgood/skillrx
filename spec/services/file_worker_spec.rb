require "rails_helper"

RSpec.describe FileWorker do
  subject(:worker) { described_class.new(share: "skillrx-test", file:, path:, name:, new_path:) }

  let(:file) { "some_content" }
  let(:path) { "destination_path" }
  let(:name) { "destination_name" }
  let(:new_path) { "new_destination_path" }

  let(:files) { instance_double("AzureFileShares::Operations::FileOperations") }

  before do
    allow(AzureFileShares).to receive_message_chain(:client, :files).and_return(files)
    allow(files).to receive(:directory_exists?).and_return(true)
    allow(files).to receive(:upload_file).with("skillrx-test", path, name, file)
  end

  context "when sending a file" do
    it "sends a temporary file to destination" do
      expect(files).to receive(:upload_file).with("skillrx-test", path, name, file)

      worker.send
    end
  end

  context "when removing a file" do
    it "deletes the file from the destination" do
      expect(files).to receive(:delete_file).with("skillrx-test", path, name)

      worker.delete
    end
  end

  context "when moving a file" do
    it "copies the file to a new path" do
      expect(files).to receive(:copy_file).with("skillrx-test", path, name, "skillrx-test", new_path, name)

      worker.copy
    end
  end
end
