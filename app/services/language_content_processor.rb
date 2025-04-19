class LanguageContentProcessor
  def initialize(language)
    @language = language
  end

  def perform
    process_language_content!
  end

  private

  attr_reader :language

  def process_language_content!
    files_to_upload.each do |file|
      FileWriter.new(file).temporary_file do |temp_file|
        FileSender.new(
          file: temp_file,
          dest: file.path,
        ).perform
      end
    end
  end

  def files_to_upload
    [
      FileToUpload.new(
        id: :all_providers,
        content: XmlGenerator::AllProviders.new(language).perform,
        name: "#{language.file_storage_prefix}Server_XML.xml",
        path: "#{language.file_storage_prefix}Server_XML.xml",
      ),
      FileToUpload.new(
        id: :all_providers_recent,
        content: XmlGenerator::AllProviders.new(language, recent: true).perform,
        name: "#{language.file_storage_prefix}New_Uploads.xml",
        path: "#{language.file_storage_prefix}New_Uploads.xml",
      ),
      FileToUpload.new(
        id: :tags,
        content: TextGenerator::Tags.new(language).perform,
        name: "#{language.file_storage_prefix}tags.txt",
        path: "#{language.file_storage_prefix}tags.txt",
      ),
      FileToUpload.new(
        id: :tags,
        content: TextGenerator::TitleAndTags.new(language).perform,
        name: "#{language.file_storage_prefix}tagsAndTitle.txt",
        path: "#{language.file_storage_prefix}tagsAndTitle.txt",
      ),
    ].tap do |files|
      language.providers.find_each do |provider|
        files << FileToUpload.new(
          id: provider.id,
          content: XmlGenerator::SingleProvider.new(provider).perform,
          name: "#{language.file_storage_prefix}#{provider.name}.xml",
          path: "#{language.file_storage_prefix}#{provider.name}.xml",
        )
        files << FileToUpload.new(
          id: "#{provider.id}_recent",
          content: XmlGenerator::SingleProvider.new(provider, recent: true).perform,
          name: "#{language.file_storage_prefix}New_#{provider.name}.xml",
          path: "#{language.file_storage_prefix}New_#{provider.name}.xml",
        )
      end
    end
  end
end
