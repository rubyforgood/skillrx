class Rack::Attack
  Rack::Attack.enabled = Rails.env.production?

  Rack::Attack.throttle("requests by ip", limit: 5, period: 2) do |request|
    request.ip
  end

  Rack::Attack.blocklist("php-bots") do |req|
    req.ip if /\S+\.php/.match?(req.path)
  end
end
