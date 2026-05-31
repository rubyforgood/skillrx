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
    language.topics.active.includes(taggings: :tag)
      .flat_map do |topic|
        topic.taggings.map do |tagging|
          [
            tagging.tag.id,
            tagging.tag.name,
          ]
        end
      end.uniq
  end
end
