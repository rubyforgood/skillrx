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
      .flat_map { |topic| topic.tags_on(language.code.to_sym) }
      .uniq
      .map do |tag|
        [
          tag.id,
          tag.name,
        ]
      end
  end
end
