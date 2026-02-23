require "rails_helper"

RSpec.describe "Beacon Authentication", type: :request do
  describe "GET /api/v1/beacons/status" do
    it "returns beacon info with a valid API key" do
      beacon, raw_key = create_beacon_with_key(name: "Test Beacon")

      get "/api/v1/beacons/status", headers: beacon_auth_headers(raw_key)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["status"]).to eq("ok")
      expect(body["beacon"]["id"]).to eq(beacon.id)
      expect(body["beacon"]["name"]).to eq("Test Beacon")
    end

    it "returns unauthorized when no authorization header is present" do
      get "/api/v1/beacons/status"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Missing authorization header")
    end

    it "returns unauthorized with an invalid API key" do
      get "/api/v1/beacons/status", headers: beacon_auth_headers("sk_live_invalid_key_000000000")

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Invalid API key")
    end

    it "returns unauthorized when the beacon is revoked" do
      beacon, raw_key = create_beacon_with_key
      beacon.revoke!

      get "/api/v1/beacons/status", headers: beacon_auth_headers(raw_key)

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("API key has been revoked")
    end

    it "returns unauthorized with a malformed authorization header" do
      get "/api/v1/beacons/status", headers: { "Authorization" => "Token sk_live_something" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Missing authorization header")
    end
  end
end
