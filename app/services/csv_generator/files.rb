class CsvGenerator::Files < CsvGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def headers
    %w[FileID TopicID FileName FileType FileSize]
  end

  def scope
    language.topics.active
      .flat_map do |topic|
        topic.documents.map do |doc|
          [
            doc.id,
            topic.id,
            topic.custom_file_name(doc),
            doc.content_type,
            doc.byte_size,
          ]
        end.compact
      end
  end
end
