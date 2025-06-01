class FileSender
  def initialize(share:, name:, path:, file:)
    @share = share
    @name = name
    @path = path
    @file = file
  end

  def perform
    send_file
  end

  private

  def send_file
    client.files.upload_file(share, path, name, file)
  end

  def client
    @client ||= AzureFileShares.client
  end

  attr_reader :share, :path, :name, :file
end
