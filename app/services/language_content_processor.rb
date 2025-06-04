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
      FileSender.new(
        share:,
        name: file.name,
        path: file.path,
        file: file.content,
      ).perform
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
        id: :tags_and_title,
        content: TextGenerator::TitleAndTags.new(language).perform,
        name: "#{language.file_storage_prefix}tagsAndTitle.txt",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      ),
      FileToUpload.new(
        id: :files,
        content: CsvGenerator::Files.new(language).perform,
        name: "#{language.file_storage_prefix}File.csv",
        path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      ),
      FileToUpload.new(
        id: :topics,
        content: CsvGenerator::Topics.new(language).perform,
        name: "#{language.file_storage_prefix}Topic.csv",
        path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      ),
      FileToUpload.new(
        id: :tag_details,
        content: CsvGenerator::TagDetails.new(language).perform,
        name: "#{language.file_storage_prefix}Tag.csv",
        path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      ),
      FileToUpload.new(
        id: :topic_tags,
        content: CsvGenerator::TopicTags.new(language).perform,
        name: "#{language.file_storage_prefix}TopicTag.csv",
        path: "#{language.file_storage_prefix}CMES-mini/assets/csv",
      ),
    ].tap do |files|
      language.providers.find_each do |provider|
        files << FileToUpload.new(
          id: provider.id,
          content: XmlGenerator::SingleProvider.new(provider).perform,
          name: "#{language.file_storage_prefix}#{provider.name}.xml",
          path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
        )
      end
    end
  end
end
