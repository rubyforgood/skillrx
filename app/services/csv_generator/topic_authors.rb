class CsvGenerator::TopicAuthors < CsvGenerator::Base
  private

  def headers
    %w[TopicID AuthorID]
  end

  def scope
    topics_collection.active.map { |topic| [ topic.id, 0 ] }
  end
end
