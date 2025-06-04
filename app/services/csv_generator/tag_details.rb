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
    language.topics.active
      .flat_map do |topic|
        topic.tags_on(language.code.to_sym)
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
