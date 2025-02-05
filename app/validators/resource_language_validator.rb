class ResourceLanguageValidator < ActiveModel::Validator
  def validate(record)
    if TrainingResource.joins(:topic)
                    .where(
                      training_resources: { file_name_override: record.file_name_override },
                      topics: { language_id: record.topic.language_id },
                    )
      .any?
      record.errors.add(:file_name_override, "This filename is already in use")
    end
  end
end
