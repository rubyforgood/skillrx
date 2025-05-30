class FileSender
  def initialize(file:, name:, path:)
    @file = file
    @name = name
    @path = path
  end

  def perform
    send_file
  end

  private

  def send_file
    client.files.upload_file("skillrx-staging-env", path, name, file)
  end

  def client
    @client ||= AzureFileShares.client
  end

  attr_reader :file, :path, :name
end
