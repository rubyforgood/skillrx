module BeaconAuthenticationHelpers
  def beacon_auth_headers(raw_key)
    { "Authorization" => "Bearer #{raw_key}" }
  end

  def create_beacon_with_key(attributes = {})
    generator = Beacons::ApiKeyGenerator.new
    key_result = generator.call

    beacon = create(:beacon, **attributes.merge(
      api_key_digest: key_result.digest,
      api_key_prefix: key_result.prefix,
    ))

    [ beacon, key_result.raw_key ]
  end
end

RSpec.configure do |config|
  config.include BeaconAuthenticationHelpers, type: :request
end
