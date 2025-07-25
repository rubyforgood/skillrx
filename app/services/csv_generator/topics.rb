class CsvGenerator::Topics < CsvGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def headers
    %w[TopicID TopicName TopicVolume TopicIssue TopicYear TopicMonth ContentProvider]
  end

  def scope
    language.topics.active
      .includes(:provider)
      .map do |topic|
        [
          topic.id,
          topic.title,
          topic.published_at.year,
          topic.published_at.month,
          topic.published_at.year,
          topic.published_at.strftime("%m_%B"),
          topic.provider.name,
        ]
      end
  end
end
