require "rails_helper"

RSpec.describe Beacons::KeyRegenerator do
  describe "#call" do
    it "generates a new key for the beacon" do
      beacon = create(:beacon)
      old_digest = beacon.api_key_digest

      regenerator = described_class.new
      _, raw_key = regenerator.call(beacon)

      expect(beacon.reload.api_key_digest).not_to eq(old_digest)
      expect(raw_key).to start_with("sk_live_")
      expect(beacon.api_key_digest).to eq(OpenSSL::Digest::SHA256.hexdigest(raw_key))
    end

    it "clears revoked_at on a revoked beacon" do
      beacon = create(:beacon, :revoked)
      expect(beacon.revoked_at).to be_present

      regenerator = described_class.new
      regenerator.call(beacon)

      expect(beacon.reload.revoked_at).to be_nil
    end

    it "accepts a custom key generator via dependency injection" do
      beacon = create(:beacon)
      fake_result = Beacons::ApiKeyGenerator::Result.new(
        raw_key: "sk_live_injected_key_1234abcd",
        digest: "injected_digest_value",
        prefix: "injected",
      )
      fake_generator = instance_double(Beacons::ApiKeyGenerator, call: fake_result)

      regenerator = described_class.new(key_generator: fake_generator)
      returned_beacon, raw_key = regenerator.call(beacon)

      expect(returned_beacon.api_key_digest).to eq("injected_digest_value")
      expect(raw_key).to eq("sk_live_injected_key_1234abcd")
    end
  end
end
