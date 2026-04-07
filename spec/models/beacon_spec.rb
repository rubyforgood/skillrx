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

  describe "#accessible_blobs" do
    let(:beacon) { create(:beacon) }
    let(:provider) { create(:provider) }
    let(:other_beacon) { create(:beacon) }

    before do
      beacon.providers << provider
      other_beacon.providers << provider
    end

    context "when beacon has topics with documents" do
      let!(:topic1) { create(:topic, :with_documents, provider: provider, language: beacon.language) }
      let!(:topic2) { create(:topic, :with_documents, provider: provider, language: beacon.language) }

      before do
        beacon.topics << topic1
        beacon.topics << topic2
      end

      it "returns blobs from all beacon topics" do
        expected_blob_ids = (topic1.documents + topic2.documents).map(&:blob_id)
        expect(beacon.accessible_blobs.pluck(:id)).to match_array(expected_blob_ids)
      end

      it "returns ActiveStorage::Blob records" do
        expect(beacon.accessible_blobs.first).to be_a(ActiveStorage::Blob)
      end
    end

    context "when beacon has no topics" do
      it "returns empty relation" do
        expect(beacon.accessible_blobs).to be_empty
      end
    end

    context "when topics have no documents" do
      let!(:topic_without_docs) { create(:topic, provider: provider, language: beacon.language) }

      before do
        beacon.topics << topic_without_docs
      end

      it "returns empty relation" do
        expect(beacon.accessible_blobs).to be_empty
      end
    end

    context "when other beacons have topics with documents" do
      let!(:beacon_topic) { create(:topic, :with_documents, provider: provider, language: beacon.language) }
      let!(:other_topic) { create(:topic, :with_documents, provider: provider, language: other_beacon.language) }

      before do
        beacon.topics << beacon_topic
        other_beacon.topics << other_topic
      end

      it "only returns blobs from this beacon's topics" do
        expected_blob_ids = beacon_topic.documents.map(&:blob_id)
        expect(beacon.accessible_blobs.pluck(:id)).to match_array(expected_blob_ids)
      end
    end
  end
end
