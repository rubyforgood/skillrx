class FileWorker
  def initialize(share:, name:, path:, file:, new_path: nil)
    @share = share
    @name = name
    @path = path
    @file = file
    @new_path = new_path
  end

  def send
    send_file
  end

  def delete
    delete_file
  end

  def copy
    copy_file(new_path)
  end

  private

  attr_reader :share, :path, :name, :file, :new_path

  def send_file
    create_subdirs(path)
    return if file.blank?

    client.files.upload_file(share, path, name, file)
  end

  def create_subdirs(current_path)
    current_path.split("/").each_with_object([]) do |dir, dirs|
      dir = dir.strip
      dirs << dir unless dir.blank?
      dir_path = dirs.join("/")
      next if dir_path.blank? || client.files.directory_exists?(share, dir_path)

      client.files.create_directory(share, dir_path)
    end
  end

  def delete_file
    client.files.delete_file(share, path, name)
  end

  def copy_file(new_path)
    create_subdirs(new_path)
    return if file.blank?

    client.files.copy_file(share, path, name, share, new_path, name)
  end

  def client
    @client ||= AzureFileShares.client
  end
end
