class FileUploadJob < ApplicationJob
  # Consider removing concurrency limits due to SolidQueue blocking issues
  # or use a more specific key to avoid blocking all jobs for a language
  limits_concurrency to: 3, key: ->(_language_id, _content_id, _content_type) { "hard-limit" }

  retry_on AzureFileShares::Errors::ApiError, wait: :exponentially_longer, attempts: 3
  retry_on Timeout::Error, wait: :exponentially_longer, attempts: 2

  discard_on StandardError do |job, error|
    Rails.logger.error "FileUploadJob failed permanently: #{error.message}"
    Rails.logger.error "Job arguments: #{job.arguments}"
    Rails.logger.error "Suggestion: Check provider names for invalid characters if Azure API errors"
  end

  def perform(language_id, file_id, provider_id = nil, share = ENV["AZURE_STORAGE_SHARE_NAME"])
    @language = Language.find(language_id)
    @share = share
    @file_id = file_id.to_sym
    @processor = LanguageContentProcessor.new(language)

    send_provider_content(provider_id) if provider_id.present?
    send_language_content if provider_id.blank?
  end

  private

  attr_reader :language, :file_id, :share, :processor

  def send_provider_content(provider_id)
    provider = language.providers.find(provider_id)
    file = processor.provider_files[file_id]
    return unless provider && file

    FileWorker.new(
      share:,
      name: file.name[provider],
      path: file.path,
      file: file.content[provider],
    ).send
  end

  def send_language_content
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
