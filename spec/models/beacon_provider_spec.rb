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
require "rails_helper"

RSpec.describe BeaconProvider, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:beacon) }
    it { is_expected.to belong_to(:provider) }
  end

  describe "callbacks" do
    let(:beacon) { create(:beacon) }
    let(:provider) { create(:provider) }

    it "enqueues a rebuild manifest job on create" do
      expect {
        create(:beacon_provider, beacon: beacon, provider: provider)
      }.to have_enqueued_job(Beacons::RebuildManifestJob).with(beacon.id)
    end

    it "enqueues a rebuild manifest job on destroy" do
      beacon_provider = create(:beacon_provider, beacon: beacon, provider: provider)

      expect {
        beacon_provider.destroy!
      }.to have_enqueued_job(Beacons::RebuildManifestJob).with(beacon.id)
    end
  end
end
