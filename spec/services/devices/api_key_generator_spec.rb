require "rails_helper"

RSpec.describe Devices::ApiKeyGenerator do
  subject(:generator) { described_class.new }

  describe "#call" do
    it "returns a result with raw_key, digest, and prefix" do
      result = generator.call

      expect(result).to respond_to(:raw_key, :digest, :prefix)
    end

    it "generates a key with the sk_live_ prefix" do
      result = generator.call

      expect(result.raw_key).to start_with("sk_live_")
    end

    it "generates a 40-character raw key" do
      result = generator.call

      # "sk_live_" (8 chars) + 32 hex chars = 40 chars
      expect(result.raw_key.length).to eq(40)
    end

    it "computes a valid SHA256 digest of the raw key" do
      result = generator.call
      expected_digest = OpenSSL::Digest::SHA256.hexdigest(result.raw_key)

      expect(result.digest).to eq(expected_digest)
    end

    it "extracts the first 8 characters after the prefix" do
      result = generator.call
      expected_prefix = result.raw_key.delete_prefix("sk_live_")[0, 8]

      expect(result.prefix).to eq(expected_prefix)
    end

    it "generates unique keys on each call" do
      results = Array.new(5) { generator.call }
      raw_keys = results.map(&:raw_key)

      expect(raw_keys.uniq.length).to eq(5)
    end
  end
end
