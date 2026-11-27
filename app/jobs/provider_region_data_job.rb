class ProviderRegionDataJob < ApplicationJob
  limits_concurrency to: 1, key: ->(language_id) { "hard-limit" }

  def perform(language_id)
    language = Language.find(language_id)
    deliver_provider_region_data(language)
  end

  private

  def deliver_provider_region_data(language)
    provider_region_data(language).tap { |file| deliver(file) }
  end

  def provider_region_data(language)
    FileToUpload.new(
      content: JsonGenerator::ProviderRegions.new(language).perform,
      name: "#{language.file_storage_prefix}provider_region_data.json",
      path: "#{language.file_storage_prefix}CMES-v2",
    )
  end

  def deliver(file)
    FileWorker.new(
      share: ENV["AZURE_STORAGE_SHARE_NAME"],
      name: file.name,
      path: file.path,
      file: file.content,
    ).send
  end
end
