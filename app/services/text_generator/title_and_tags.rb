class TextGenerator::TitleAndTags < TextGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def text_content
    scope
      .flat_map do |topic|
        [ topic.title ] + topic.tags
      end
      .join("\n")
  end

  def scope
    language.topics.includes(:tags).active
  end
end
