# == Schema Information
#
# Table name: beacon_providers
# Database name: primary
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  beacon_id   :bigint           not null
#  provider_id :bigint           not null
#
# Indexes
#
#  index_beacon_providers_on_beacon_id                  (beacon_id)
#  index_beacon_providers_on_beacon_id_and_provider_id  (beacon_id,provider_id) UNIQUE
#  index_beacon_providers_on_provider_id                (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (beacon_id => beacons.id)
#  fk_rails_...  (provider_id => providers.id)
#
class BeaconProvider < ApplicationRecord
  belongs_to :beacon
  belongs_to :provider
end
