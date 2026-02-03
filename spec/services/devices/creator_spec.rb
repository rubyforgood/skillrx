require "rails_helper"

RSpec.describe Devices::Creator do
  describe "#call" do
    let(:language) { create(:language) }

    it "creates a device and returns the raw key" do
      creator = described_class.new
      success, device, raw_key = creator.call(name: "Test Device", language: language)

      expect(success).to be true
      expect(device).to be_persisted
      expect(raw_key).to start_with("sk_live_")
    end

    it "sets the api_key_digest and api_key_prefix on the device" do
      creator = described_class.new
      _, device, raw_key = creator.call(name: "Test Device", language: language)
      expected_digest = OpenSSL::Digest::SHA256.hexdigest(raw_key)

      expect(device.api_key_digest).to eq(expected_digest)
      expect(device.api_key_prefix).to eq(raw_key.delete_prefix("sk_live_")[0, 8])
    end

    it "returns failure when params are invalid" do
      creator = described_class.new
      success, device, raw_key = creator.call(name: "", language: language)

      expect(success).to be false
      expect(device).not_to be_persisted
      expect(raw_key).to be_nil
    end

    it "accepts a custom key generator via dependency injection" do
      fake_result = Devices::ApiKeyGenerator::Result.new(
        raw_key: "sk_live_custom1234567890abcdef",
        digest: "fake_digest_value",
        prefix: "custom12",
      )
      fake_generator = instance_double(Devices::ApiKeyGenerator, call: fake_result)
      creator = described_class.new(key_generator: fake_generator)

      success, device, raw_key = creator.call(name: "Test Device", language: language)

      expect(success).to be true
      expect(device.api_key_digest).to eq("fake_digest_value")
      expect(raw_key).to eq("sk_live_custom1234567890abcdef")
    end
  end
end
