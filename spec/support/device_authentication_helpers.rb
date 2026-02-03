module DeviceAuthenticationHelpers
  def device_auth_headers(raw_key)
    { "Authorization" => "Bearer #{raw_key}" }
  end

  def create_device_with_key(attributes = {})
    generator = Devices::ApiKeyGenerator.new
    key_result = generator.call

    device = create(:device, **attributes.merge(
      api_key_digest: key_result.digest,
      api_key_prefix: key_result.prefix,
    ))

    [ device, key_result.raw_key ]
  end
end

RSpec.configure do |config|
  config.include DeviceAuthenticationHelpers, type: :request
end
