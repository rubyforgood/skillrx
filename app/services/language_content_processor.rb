class LanguageContentProcessor
  # def perform
  #   Language.all.reduce({}) do |hash, language|
  #     hash[language.id] = generate_content(language)
  #     hash
  #   end
  # end

  def initialize(language)
    @language = language
  end

  def perform
    process_language_content
  end

  private

  attr_reader :language

  def process_language_content
    files_to_upload.each do |file|
      FileWriter.new(file).temporary_file do |temp_file|
        FileSender.new(
          file: temp_file,
          dest: file.path,
        ).perform
      end
    end
  end

  # def generate_content(language)
  #   {
  #     title_and_tags: TextGenerator::TitleAndTags.new(language).perform,
  #     tags: TextGenerator::Tags.new(language).perform,
  #     all_providers: XmlGenerator::AllProviders.new(language).perform,
  #   }.tap do |content|
  #     language.providers.find_each do |provider|
  #       content[provider.name] = XmlGenerator::SingleProvider.new(provider).perform
  #     end
  #   end

  #   # Save or process the generated content as needed
  #   # save_language_content(language, language_content)
  # end

  def files_to_upload
    [
      FileToUpload.new(
        id: :all_providers,
        content: XmlGenerator::AllProviders.new(language).perform,
        name: "#{language.file_storage_prefix}_all_providers.xml",
      ),
    ]
  end
end
