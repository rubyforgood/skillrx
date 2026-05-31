class SynchronizeCognatesOnTopicsJob < ApplicationJob
  def perform(tag)
    modified_topic_ids = []

    Topic.where(id: tag.taggings.select(:taggable_id)).each do |topic|
      tags = topic.tag_list << tag.cognates_tags.uniq.pluck(:name)
      topic.tag_list.add(tags)
      modified_topic_ids << topic.id if topic.save
    end

    rebuild_beacon_manifests(modified_topic_ids)
  end

  private

  def rebuild_beacon_manifests(topic_ids)
    return if topic_ids.empty?

    beacon_ids = BeaconTopic.where(topic_id: topic_ids).distinct.pluck(:beacon_id)
    beacon_ids.each do |beacon_id|
      Beacons::RebuildManifestJob.perform_later(beacon_id)
    end
  end
end
