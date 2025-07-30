class TextGenerator::Tags < TextGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def text_content
    scope
      .flat_map { |topic| topic.current_tags_list }
      .uniq
      .sort
      .join("\n")
  end

  def scope
    language.topics.active
  end
end
