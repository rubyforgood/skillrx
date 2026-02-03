module Devices
  class ApiKeyGenerator
    PREFIX = "sk_live_"

    def call
      raw_key = "#{PREFIX}#{SecureRandom.hex(16)}"
      digest = OpenSSL::Digest::SHA256.hexdigest(raw_key)
      prefix = raw_key.delete_prefix(PREFIX)[0, 8]

      Result.new(raw_key: raw_key, digest: digest, prefix: prefix)
    end

    Result = Data.define(:raw_key, :digest, :prefix)
  end
end
