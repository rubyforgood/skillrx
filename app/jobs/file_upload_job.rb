class FileUploadJob < ApplicationJob
  # Consider removing concurrency limits due to SolidQueue blocking issues
  # or use a more specific key to avoid blocking all jobs for a language
  limits_concurrency key: ->(language_id, file_id, provider_id) { "#{language_id}-#{provider_id}" }
  
  retry_on AzureFileShares::Errors::ApiError, wait: :exponentially_longer, attempts: 3
  retry_on Timeout::Error, wait: :exponentially_longer, attempts: 2
  
  discard_on StandardError do |job, error|
    Rails.logger.error "FileUploadJob failed permanently: #{error.message}"
    Rails.logger.error "Job arguments: #{job.arguments}"
    Rails.logger.error "Suggestion: Check provider names for invalid characters if Azure API errors"
  end

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
