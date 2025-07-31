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
    allow(files).to receive(:upload_file)
    allow(files).to receive(:create_directory)
  end

  context "when sending a file" do
    it "sends a temporary file to destination with timeout" do
      expect(Timeout).to receive(:timeout).with(30, Timeout::Error, anything).and_yield
      expect(files).to receive(:upload_file).with("skillrx-test", path, name, file)

      worker.send
    end

    it "logs warnings for invalid filenames" do
      worker_with_invalid_name = described_class.new(
        share: "skillrx-test",
        file: file,
        path: path,
        name: "WHO/Guidelines.xml"
      )

      expect(Rails.logger).to receive(:warn).with(/Invalid filename detected/)
      expect(Rails.logger).to receive(:warn).with(/Contains invalid characters: \//)
      expect(Rails.logger).to receive(:warn).with(/This will likely cause Azure FileShares API failures/)
      expect(Rails.logger).to receive(:warn).with(/Provider should be renamed/)

      allow(Timeout).to receive(:timeout).and_yield
      allow(files).to receive(:upload_file)

      worker_with_invalid_name.send
    end

    it "handles timeout errors with proper logging" do
      allow(Timeout).to receive(:timeout).and_raise(Timeout::Error.new("Upload timed out"))

      expect(Rails.logger).to receive(:error).with(/Upload timeout/)
      expect(Rails.logger).to receive(:error).with(/File: #{name}/)

      expect { worker.send }.to raise_error(Timeout::Error)
    end

    it "handles Azure API errors with helpful logging" do
      allow(Timeout).to receive(:timeout).and_yield
      allow(files).to receive(:upload_file).and_raise(AzureFileShares::Errors::ApiError.new("ParentNotFound"))

      expect(Rails.logger).to receive(:error).with(/Azure API Error/)
      expect(Rails.logger).to receive(:error).with(/File: #{name}/)
      expect(Rails.logger).to receive(:error).with(/Hint: Check if filename contains invalid characters/)

      expect { worker.send }.to raise_error(AzureFileShares::Errors::ApiError)
    end

    it "does not upload blank files" do
      worker_with_blank_file = described_class.new(
        share: "skillrx-test",
        file: "",
        path: path,
        name: name
      )

      expect(files).not_to receive(:upload_file)

      worker_with_blank_file.send
    end
  end

  describe "#create_subdirs" do
    let(:path) { "level1/level2/level3" }

    before do
      allow(files).to receive(:directory_exists?).and_return(false)
    end

    it "creates all directory levels that don't exist" do
      expect(files).to receive(:directory_exists?).with("skillrx-test", "level1")
      expect(files).to receive(:directory_exists?).with("skillrx-test", "level1/level2")
      expect(files).to receive(:directory_exists?).with("skillrx-test", "level1/level2/level3")

      expect(files).to receive(:create_directory).with("skillrx-test", "level1")
      expect(files).to receive(:create_directory).with("skillrx-test", "level1/level2")
      expect(files).to receive(:create_directory).with("skillrx-test", "level1/level2/level3")

      worker.__send__(:create_subdirs, path)
    end

    it "skips existing directories" do
      allow(files).to receive(:directory_exists?).with("skillrx-test", "level1").and_return(true)

      expect(files).not_to receive(:create_directory).with("skillrx-test", "level1")
      expect(files).to receive(:create_directory).with("skillrx-test", "level1/level2")
      expect(files).to receive(:create_directory).with("skillrx-test", "level1/level2/level3")

      worker.__send__(:create_subdirs, path)
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
