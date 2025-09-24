class SynchronizeCognatesOnTopicsJob < ApplicationJob
  def perform(tag)
    Topic.where(id: tag.taggings.select(:taggable_id)).each do |topic|
      tags = topic.current_tags_list << tag.cognates_tags.uniq.pluck(:name)
      topic.tag_list.add(tags)
      topic.save
    end
  end
end
