class FileSender
  def initialize(file:, dest:)
    @file = file
    @dest = dest
  end

  def perform
    send_file
  end

  private

  def send_file
    # Simulate sending the file to a remote server
    # In a real-world scenario, this could involve using an API or FTP
    # For demonstration purposes, we'll just print the file details
    Rails.logger.info "Sending file '#{file.path}' to destination '#{dest}'"
    Rails.logger.info "File content: #{file.read}"
    # Here you would implement the actual file transfer logic
    # For example, using Net::FTP or an HTTP client to upload the file
    # For now, we'll just simulate a successful transfer
    Rails.logger.info "File '#{file.path}' sent successfully to '#{dest}'"
  end

  attr_reader :file, :dest
end
