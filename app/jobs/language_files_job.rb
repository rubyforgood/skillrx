class LanguageFilesJob < ApplicationJob
  limits_concurrency to: 1, key: ->(language_id) { "hard-limit" }

  def perform(language_id)
    language = Language.find(language_id)
    LanguageContentProcessor.new(language).perform
  end
end
