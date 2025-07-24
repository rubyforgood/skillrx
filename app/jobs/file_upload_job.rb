class FileUploadJob < ApplicationJob
  def perform(language_id, file_id = nil, provider_id = nil, share = ENV["AZURE_STORAGE_SHARE_NAME"])
    @language = Language.find(language_id)
    @processor = LanguageContentProcessor.new(language)
    @share = share

    if provider_id
      send_provider_content(provider_id)
      return
    end

    send_language_content(file_id.to_sym)
  end

  private

  attr_reader :language, :processor, :share

  def send_provider_content(provider_id)
    provider = language.providers.find(provider_id)
    return unless provider

    processor.provider_files.each do |file|
      FileWorker.new(
        share:,
        name: file.name[provider],
        path: file.path,
        file: file.content[provider],
      ).send
    end
  end

  def send_language_content(file_id)
    file = processor.language_files[file_id]
    return unless file

    FileWorker.new(
      share:,
      name: file.name,
      path: file.path,
      file: file.content[language],
    ).send
  end
end
