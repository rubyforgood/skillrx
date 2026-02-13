# == Schema Information
#
# Table name: beacons
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  api_key_digest         :string           not null
#  api_key_prefix         :string           not null
#  manifest_checksum      :string
#  manifest_data          :jsonb
#  manifest_version       :integer          default(0), not null
#  name                   :string           not null
#  previous_manifest_data :jsonb
#  revoked_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :bigint           not null
#  region_id              :bigint           not null
#
# Indexes
#
#  index_beacons_on_api_key_digest  (api_key_digest) UNIQUE
#  index_beacons_on_language_id     (language_id)
#  index_beacons_on_region_id       (region_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (region_id => regions.id)
#
require "rails_helper"

RSpec.describe Beacon, type: :model do
  subject { create(:beacon) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:api_key_digest) }
    it { is_expected.to validate_uniqueness_of(:api_key_digest) }
    it { is_expected.to validate_presence_of(:api_key_prefix) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:language) }
    it { is_expected.to belong_to(:region) }
    it { is_expected.to have_many(:beacon_providers).dependent(:destroy) }
    it { is_expected.to have_many(:providers).through(:beacon_providers) }
    it { is_expected.to have_many(:beacon_topics).dependent(:destroy) }
    it { is_expected.to have_many(:topics).through(:beacon_topics) }
  end

  describe "scopes" do
    let!(:active_beacon) { create(:beacon) }
    let!(:revoked_beacon) { create(:beacon, :revoked) }

    describe ".active" do
      it "returns only active beacons" do
        expect(described_class.active).to contain_exactly(active_beacon)
      end
    end

    describe ".revoked" do
      it "returns only revoked beacons" do
        expect(described_class.revoked).to contain_exactly(revoked_beacon)
      end
    end
  end

  describe "#regenerate" do
    it "reassigns the API key's prefix and digest" do
      beacon = create(:beacon)

      expect { beacon.regenerate }.to change { beacon.api_key_digest }
        .and change { beacon.api_key_prefix }
    end

    it "sets revoked_at to nil" do
      beacon = create(:beacon, :revoked)

      beacon.regenerate
      expect(beacon.revoked_at).to be_nil
    end
  end

  describe "#revoke!" do
    include ActiveSupport::Testing::TimeHelpers

    it "sets revoked_at to the current time" do
      beacon = create(:beacon)
      now = Time.current

      travel_to(now) do
        beacon.revoke!
        expect(beacon.revoked_at).to be_within(1.second).of(now)
      end
    end
  end

  describe "#revoked?" do
    it "returns false for active beacons" do
      beacon = create(:beacon)
      expect(beacon).not_to be_revoked
    end

    it "returns true for revoked beacons" do
      beacon = create(:beacon, :revoked)
      expect(beacon).to be_revoked
    end
  end
end
