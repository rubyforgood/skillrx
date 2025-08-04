class Rack::Attack
  Rack::Attack.enabled = Rails.env.production?

  Rack::Attack.blocklist("php-bots") do |req|
    req.ip if /\S+\.php/.match?(req.path)
  end
end
