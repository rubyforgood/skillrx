class TextGenerator::TitleAndTags < TextGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def text_content
    language.topics
      .map do |topic|
        ([ topic.title ] + topic.current_tags_list).join(",")
      end
      .join("\n")
  end
end
