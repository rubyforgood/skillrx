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
    create_subdirs()
    return if file.blank?

    client.files.upload_file(share, path, name, file)
  end

  def create_subdirs
    path.split("/").each_with_object([]) do |dir, dirs|
      dir = dir.strip
      dirs << dir unless dir.blank?
      dir_path = dirs.join("/")
      next if dir_path.blank? || client.files.directory_exists?(share, dir_path)

      client.files.create_directory(share, dir_path)
    end
  end

  def client
    @client ||= AzureFileShares.client
  end

  attr_reader :share, :path, :name, :file
end
