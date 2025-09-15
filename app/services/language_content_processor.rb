class LanguageContentProcessor
  def initialize(language, share = ENV["AZURE_STORAGE_SHARE_NAME"])
    @language = language
    @share = share
  end

  def perform
    process_language_content!
  end

  # Field 'content' is a lambda to allow lazy evaluation
  # this is needed to avoid loading all files into memory at once
  # Field 'name' is a lambda to allow dynamic naming based on the provider
  def provider_files
    [
      FileToUpload.new(
        content: ->(provider) { XmlGenerator::SingleProvider.new(provider).perform },
        name: ->(provider) { "#{language.file_storage_prefix}#{provider.name.parameterize}.xml" },
        path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      ),
    ]
  end

  # Field 'content' is a lambda to allow lazy evaluation
  # this is needed to avoid loading all files into memory at once
  def language_files
    {
      all_providers: FileToUpload.new(
        content: ->(language) { XmlGenerator::AllProviders.new(language).perform },
        name: "#{language.file_storage_prefix}Server_XML.xml",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      ),
      all_providers_recent: FileToUpload.new(
        content: ->(language) { XmlGenerator::AllProviders.new(language, recent: true).perform },
        name: "#{language.file_storage_prefix}New_Uploads.xml",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/XML",
      ),
      tags: FileToUpload.new(
        content: ->(language) { TextGenerator::Tags.new(language).perform },
        name: "#{language.file_storage_prefix}tags.txt",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      ),
      tags_and_title: FileToUpload.new(
        content: ->(language) { TextGenerator::TitleAndTags.new(language).perform },
        name: "#{language.file_storage_prefix}tagsAndTitle.txt",
        path: "#{language.file_storage_prefix}CMES-Pi/assets/Tags",
      ),
      files: FileToUpload.new(
        content: ->(language) { CsvGenerator::Files.new(language).perform },
        name: "#{language.file_storage_prefix}File.csv",
        path: "#{language.file_storage_prefix}CMES-v2/assets/csv",
      ),
      topics: FileToUpload.new(
        content: ->(language) { CsvGenerator::Topics.new(language).perform },
        name: "#{language.file_storage_prefix}Topic.csv",
        path: "#{language.file_storage_prefix}CMES-v2/assets/csv",
      ),
      tag_details: FileToUpload.new(
        content: ->(language) { CsvGenerator::TagDetails.new(language).perform },
        name: "#{language.file_storage_prefix}Tag.csv",
        path: "#{language.file_storage_prefix}CMES-v2/assets/csv",
      ),
      topic_tags: FileToUpload.new(
        content: ->(language) { CsvGenerator::TopicTags.new(language).perform },
        name: "#{language.file_storage_prefix}TopicTag.csv",
        path: "#{language.file_storage_prefix}CMES-v2/assets/csv",
      ),
        topic_authors: FileToUpload.new(
        content: ->(language) { CsvGenerator::TopicAuthors.new(language).perform },
        name: "#{language.file_storage_prefix}TopicAuthor.csv",
        path: "#{language.file_storage_prefix}CMES-v2/assets/csv",
      ),
    }
  end

  private

  attr_reader :language, :share

  def process_language_content!
    language_files.keys.each do |file_id|
      FileUploadJob.perform_later(language.id, file_id.to_s, "file")
    end

    language.providers.distinct.find_each do |provider|
      FileUploadJob.perform_later(language.id, provider.id, "provider")
    end
  end
end
