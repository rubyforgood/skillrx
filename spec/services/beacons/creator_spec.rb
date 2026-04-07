require "rails_helper"

RSpec.describe Beacons::Creator do
  describe "#call" do
    let(:language) { create(:language) }
    let(:region) { create(:region) }

    it "creates a beacon and returns the raw key" do
      creator = described_class.new
      success, beacon, raw_key = creator.call(name: "Test Beacon", language: language, region: region)

      expect(success).to be true
      expect(beacon).to be_persisted
      expect(raw_key).to start_with("sk_live_")
    end

    it "sets the api_key_digest and api_key_prefix on the beacon" do
      creator = described_class.new
      _, beacon, raw_key = creator.call(name: "Test Beacon", language: language, region: region)
      expected_digest = OpenSSL::Digest::SHA256.hexdigest(raw_key)

      expect(beacon.api_key_digest).to eq(expected_digest)
      expect(beacon.api_key_prefix).to eq(raw_key.delete_prefix("sk_live_")[0, 8])
    end

    it "returns failure when params are invalid" do
      creator = described_class.new
      success, beacon, raw_key = creator.call(name: "", language: language, region: region)

      expect(success).to be false
      expect(beacon).not_to be_persisted
      expect(raw_key).to be_nil
    end

    it "accepts a custom key generator via dependency injection" do
      fake_result = Beacons::ApiKeyGenerator::Result.new(
        raw_key: "sk_live_custom1234567890abcdef",
        digest: "fake_digest_value",
        prefix: "custom12",
      )
      fake_generator = instance_double(Beacons::ApiKeyGenerator, call: fake_result)
      creator = described_class.new(key_generator: fake_generator)

      success, beacon, raw_key = creator.call(name: "Test Beacon", language: language, region: region)

      expect(success).to be true
      expect(beacon.api_key_digest).to eq("fake_digest_value")
      expect(raw_key).to eq("sk_live_custom1234567890abcdef")
    end
  end
end
