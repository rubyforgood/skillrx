module Devices
  class Creator
    attr_reader :key_generator

    def initialize(key_generator: ApiKeyGenerator.new)
      @key_generator = key_generator
    end

    def call(params)
      key_result = key_generator.call

      device = Device.new(
        **params,
        api_key_digest: key_result.digest,
        api_key_prefix: key_result.prefix,
      )

      if device.save
        [ true, device, key_result.raw_key ]
      else
        [ false, device, nil ]
      end
    end
  end
end
