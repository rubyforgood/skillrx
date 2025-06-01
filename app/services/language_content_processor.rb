class LanguageContentProcessor
  def initialize(language, share = ENV["AZURE_STORAGE_SHARE_NAME"])
    @language = language
    @share = share
  end

  def perform
    process_language_content!
  end

  private

  attr_reader :language, :share

  def process_language_content!
    files_to_upload.each do |file|
      FileWriter.new(file).temporary_file do |temp_file|
        FileSender.new(
          share:,
          name: file.name,
          path: file.path,
          file: temp_file,
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
        path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      ),
      FileToUpload.new(
        id: :all_providers_recent,
        content: XmlGenerator::AllProviders.new(language, recent: true).perform,
        name: "#{language.file_storage_prefix}New_Uploads_Server_XML.xml",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      ),
      FileToUpload.new(
        id: :tags,
        content: TextGenerator::Tags.new(language).perform,
        name: "#{language.file_storage_prefix}tags.txt",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      ),
      FileToUpload.new(
        id: :tags,
        content: TextGenerator::TitleAndTags.new(language).perform,
        name: "#{language.file_storage_prefix}tagsAndTitle.txt",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      ),
    ].tap do |files|
      language.providers.find_each do |provider|
        files << FileToUpload.new(
          id: provider.id,
          content: XmlGenerator::SingleProvider.new(provider).perform,
          name: "#{language.file_storage_prefix}#{provider.name}.xml",
          path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",

        )
        files << FileToUpload.new(
          id: "#{provider.id}_recent",
          content: XmlGenerator::SingleProvider.new(provider, recent: true).perform,
          name: "#{language.file_storage_prefix}New_Uploads_#{provider.name}.xml",
          path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
        )
      end
    end
  end
end
