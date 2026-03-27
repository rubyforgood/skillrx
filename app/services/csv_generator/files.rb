class CsvGenerator::Files < CsvGenerator::Base
  private

  def headers
    %w[FileID TopicID FileName FileType FileSize]
  end

  def scope
    topics_collection.active
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
