class LanguageContentGenerator
  def perform
    Language.all.reduce({}) do |hash, language|
      hash[language.id] = generate_content(language)
      hash
    end
  end

  private

  def generate_content(language)
    {
      title_and_tags: TextGenerator::TitleAndTags.new(language).perform,
      tags: TextGenerator::Tags.new(language).perform,
      all_providers: XmlGenerator::AllProviders.new(language).perform,
    }.tap do |content|
      language.providers.find_each do |provider|
        content[provider.name] = XmlGenerator::SingleProvider.new(provider).perform
      end
    end

    # Save or process the generated content as needed
    # save_language_content(language, language_content)
  end
end
