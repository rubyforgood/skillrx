class SynchronizeCognatesOnTopicsJob < ApplicationJob
  def perform(tag)
    Topic.where(id: tag.taggings.select(:taggable_id)).each do |topic|
      tags = topic.current_tags_list << tag.cognates_tags.for_context(topic.language_code).uniq.pluck(:name)
      topic.set_tag_list_on(topic.language_code, tags)
      topic.save
    end
  end
end
