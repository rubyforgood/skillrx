class CsvGenerator::TagDetails < CsvGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def headers
    %w[TagID Tag]
  end

  def scope
    language.topics.active.includes(:tags)
      .flat_map do |topic|
        topic.tags # since we are already handling the language limitation when adding tags, we can add them directly
      end
      .uniq
      .map do |tag|
        [
          tag.id,
          tag.name,
        ]
      end
  end
end
