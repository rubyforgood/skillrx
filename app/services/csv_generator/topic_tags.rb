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
    language.topics.active.includes(:tags) # try joining tags
      .flat_map do |topic|
        topic.tags do |tag|
          [
            topic.id,
            tag.id,
          ]
        end
      end
  end
end
