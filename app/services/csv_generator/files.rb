class CsvGenerator::Files < CsvGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def headers
    %w[TopicID FileName FileType FileSize]
  end

  def scope
    language.topics.active # try joining documents
      .flat_map do |topic|
        topic.documents.map do |doc|
          [
            topic.id,
            doc.filename,
            doc.content_type,
            doc.byte_size,
          ]
        end.compact
      end
  end
end
