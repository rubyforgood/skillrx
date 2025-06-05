class LanguageFilesScheduler
  def perform
    Language.find_each do |language|
      LanguageFilesJob.perform_later(language.id)
    end
  end
end
