class FileWriter
  def initialize(file)
    @file = file
  end

  def temporary_file(&block)
    process_temp_file_add_delete
  end

  private

  def process_temp_file_add_delete
    temp_file = Tempfile.new(file.name)
    temp_file.write(file.content)
    temp_file.rewind

    yield temp_file if block_given?
  ensure
    temp_file.close
    temp_file.unlink
  end

  attr_reader :file
end
