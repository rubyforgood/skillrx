require "rails_helper"

RSpec.describe FileSender do
  subject(:sender) { described_class.new(file:, dest:) }

  let(:file) { Tempfile.new("file_name") }
  let(:dest) { "destination_path" }

  before do
    allow(Rails.logger).to receive(:info)
  end

  it "sends a temporary file to destination" do
    expect(Rails.logger).to receive(:info).with("File '#{file.path}' sent successfully to '#{dest}'")

    sender.perform
  end
end
