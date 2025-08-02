class FileWorker
  UPLOAD_TIMEOUT = 300

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
    validate_filename
    return if file.blank?

    create_subdirs(path)

    with_timeout do
      client.files.upload_file(share, path, name, file)
    end
  end

  def delete_file
    validate_filename

    with_timeout do
      client.files.delete_file(share, path, name)
    end
  end

  def copy_file(new_path)
    validate_filename
    return if file.blank?

    create_subdirs(new_path)

    with_timeout do
      client.files.copy_file(share, path, name, share, new_path, name)
    end
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

  def client
    @client ||= AzureFileShares.client
  end

  def validate_filename
    invalid_chars = name.scan(/[\/\\<>:"|?*]/)
    return if invalid_chars.empty?

    Rails.logger.warn "[FileWorker] Invalid filename detected: '#{name}'"
    Rails.logger.warn "[FileWorker] Contains invalid characters: #{invalid_chars.uniq.join(', ')}"
    Rails.logger.warn "[FileWorker] This will likely cause Azure FileShares API failures"
    Rails.logger.warn "[FileWorker] Provider should be renamed to avoid these characters: /\\<>:\"|?*"
  end

  def with_timeout(&block)
    Timeout.timeout(UPLOAD_TIMEOUT, Timeout::Error, "Azure FileShares upload timed out after #{UPLOAD_TIMEOUT} seconds") do
      block.call
    end
  rescue Timeout::Error => e
    Rails.logger.error "[FileWorker] Upload timeout: #{e.message}"
    Rails.logger.error "[FileWorker] File: #{name}, Path: #{path}"
    raise
  rescue AzureFileShares::Errors::ApiError => e
    Rails.logger.error "[FileWorker] Azure API Error: #{e.message}"
    Rails.logger.error "[FileWorker] File: #{name}, Path: #{path}"
    Rails.logger.error "[FileWorker] Hint: Check if filename contains invalid characters"
    raise
  end
end
