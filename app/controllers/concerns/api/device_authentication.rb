module Api
  module DeviceAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_device!
    end

    private

    def authenticate_device!
      token = extract_bearer_token
      return render_unauthorized("Missing authorization header") if token.blank?

      digest = OpenSSL::Digest::SHA256.hexdigest(token)
      device = Device.find_by(api_key_digest: digest)

      return render_unauthorized("Invalid API key") if device.nil?
      return render_unauthorized("API key has been revoked") if device.revoked?

      Current.device = device
    end

    def extract_bearer_token
      header = request.headers["Authorization"]
      return nil if header.blank?

      header[/\ABearer\s+(.+)\z/, 1]
    end

    def render_unauthorized(message)
      render json: { error: message }, status: :unauthorized
    end
  end
end
