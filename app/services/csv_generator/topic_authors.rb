class CsvGenerator::TopicAuthors < CsvGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def headers
    %w[TopicID AuthorID]
  end

  def scope
    language.topics.active.map { |topic| [ topic.id, 0 ] }
  end
end
