require "rails_helper"

RSpec.describe Devices::KeyRegenerator do
  describe "#call" do
    it "generates a new key for the device" do
      device = create(:device)
      old_digest = device.api_key_digest

      regenerator = described_class.new
      _, raw_key = regenerator.call(device)

      expect(device.reload.api_key_digest).not_to eq(old_digest)
      expect(raw_key).to start_with("sk_live_")
      expect(device.api_key_digest).to eq(OpenSSL::Digest::SHA256.hexdigest(raw_key))
    end

    it "clears revoked_at on a revoked device" do
      device = create(:device, :revoked)
      expect(device.revoked_at).to be_present

      regenerator = described_class.new
      regenerator.call(device)

      expect(device.reload.revoked_at).to be_nil
    end

    it "accepts a custom key generator via dependency injection" do
      device = create(:device)
      fake_result = Devices::ApiKeyGenerator::Result.new(
        raw_key: "sk_live_injected_key_1234abcd",
        digest: "injected_digest_value",
        prefix: "injected",
      )
      fake_generator = instance_double(Devices::ApiKeyGenerator, call: fake_result)

      regenerator = described_class.new(key_generator: fake_generator)
      returned_device, raw_key = regenerator.call(device)

      expect(returned_device.api_key_digest).to eq("injected_digest_value")
      expect(raw_key).to eq("sk_live_injected_key_1234abcd")
    end
  end
end
