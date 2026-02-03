# == Schema Information
#
# Table name: device_topics
# Database name: primary
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  device_id  :bigint           not null
#  topic_id   :bigint           not null
#
# Indexes
#
#  index_device_topics_on_device_id               (device_id)
#  index_device_topics_on_device_id_and_topic_id  (device_id,topic_id) UNIQUE
#  index_device_topics_on_topic_id                (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (topic_id => topics.id)
#
require "rails_helper"

RSpec.describe DeviceTopic, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:device) }
    it { is_expected.to belong_to(:topic) }
  end
end
