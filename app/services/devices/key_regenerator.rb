module Devices
  class KeyRegenerator
    attr_reader :key_generator

    def initialize(key_generator: ApiKeyGenerator.new)
      @key_generator = key_generator
    end

    def call(device)
      key_result = key_generator.call

      device.update!(
        api_key_digest: key_result.digest,
        api_key_prefix: key_result.prefix,
        revoked_at: nil,
      )

      [ device, key_result.raw_key ]
    end
  end
end
