# == Schema Information
#
# Table name: beacon_topics
# Database name: primary
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  beacon_id  :bigint           not null
#  topic_id   :bigint           not null
#
# Indexes
#
#  index_beacon_topics_on_beacon_id               (beacon_id)
#  index_beacon_topics_on_beacon_id_and_topic_id  (beacon_id,topic_id) UNIQUE
#  index_beacon_topics_on_topic_id                (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (beacon_id => beacons.id)
#  fk_rails_...  (topic_id => topics.id)
#
class BeaconTopic < ApplicationRecord
  belongs_to :beacon
  belongs_to :topic
end
