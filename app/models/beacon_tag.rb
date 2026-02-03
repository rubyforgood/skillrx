# == Schema Information
#
# Table name: beacon_tags
#
#  id         :bigint           not null, primary key
#  beacon_id  :bigint
#  tag_id     :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_beacon_tags_on_beacon_id              (beacon_id)
#  index_beacon_tags_on_tag_id                 (tag_id)
#  index_beacon_tags_on_beacon_id_and_tag_id   (beacon_id, tag_id) UNIQUE
#
class BeaconTag < ApplicationRecord
  belongs_to :beacon
  belongs_to :tag
end
