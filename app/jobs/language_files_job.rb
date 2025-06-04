class LanguageFilesJob < ApplicationJob
  def perform(language_id)
    language = Language.find(language_id)
    LanguageContentProcessor.new(language).perform
  end
end
