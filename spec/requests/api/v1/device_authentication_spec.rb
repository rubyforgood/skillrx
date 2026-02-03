require "rails_helper"

RSpec.describe "Device Authentication", type: :request do
  describe "GET /api/v1/devices/status" do
    it "returns device info with a valid API key" do
      device, raw_key = create_device_with_key(name: "Test Device")

      get "/api/v1/devices/status", headers: device_auth_headers(raw_key)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["status"]).to eq("ok")
      expect(body["device"]["id"]).to eq(device.id)
      expect(body["device"]["name"]).to eq("Test Device")
    end

    it "returns unauthorized when no authorization header is present" do
      get "/api/v1/devices/status"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Missing authorization header")
    end

    it "returns unauthorized with an invalid API key" do
      get "/api/v1/devices/status", headers: device_auth_headers("sk_live_invalid_key_000000000")

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Invalid API key")
    end

    it "returns unauthorized when the device is revoked" do
      device, raw_key = create_device_with_key
      device.revoke!

      get "/api/v1/devices/status", headers: device_auth_headers(raw_key)

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("API key has been revoked")
    end

    it "returns unauthorized with a malformed authorization header" do
      get "/api/v1/devices/status", headers: { "Authorization" => "Token sk_live_something" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Missing authorization header")
    end
  end
end
