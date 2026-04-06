class CsvGenerator::TopicTags < CsvGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def headers
    %w[TopicID TagID]
  end

  def scope
    language.topics.active.includes(:tags)
      .flat_map do |topic|
        topic.taggings.map do |tagging|
          [
            topic.id,
            tagging.tag.id,
          ]
        end
      end.uniq
  end
end
