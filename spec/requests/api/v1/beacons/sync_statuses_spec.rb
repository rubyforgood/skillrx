require "rails_helper"

RSpec.describe "Beacons Sync Status API", type: :request do
  let(:beacon_with_key) { create_beacon_with_key }
  let(:beacon) { beacon_with_key.first }
  let(:raw_key) { beacon_with_key.last }

  let(:valid_payload) do
    {
      status: "synced",
      manifest_version: "v43",
      manifest_checksum: "sha256:xyz",
      synced_at: "2026-04-21T11:59:00Z",
      files_count: 47,
      total_size_bytes: 156_000_000,
      device_info: {
        hostname: "clinic-pc-001",
        os_version: "Ubuntu 22.04",
        app_version: "1.0.0",
      },
    }
  end

  describe "POST /api/v1/beacons/sync_status" do
    context "with a valid payload" do
      it "returns 200 OK with an acknowledgment" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload,
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["status"]).to eq("accepted")
      end

      it "stores the reported fields on the beacon" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload,
          headers: beacon_auth_headers(raw_key),
          as: :json

        beacon.reload
        expect(beacon.sync_status).to eq("synced")
        expect(beacon.reported_manifest_version).to eq("v43")
        expect(beacon.reported_manifest_checksum).to eq("sha256:xyz")
        expect(beacon.reported_files_count).to eq(47)
        expect(beacon.reported_total_size_bytes).to eq(156_000_000)
        expect(beacon.device_info).to include("hostname" => "clinic-pc-001")
      end

      it "updates last_seen_at and last_sync_at" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload,
          headers: beacon_auth_headers(raw_key),
          as: :json

        beacon.reload
        expect(beacon.last_seen_at).to be_within(5.seconds).of(Time.current)
        expect(beacon.last_sync_at).to eq(Time.iso8601("2026-04-21T11:59:00Z"))
      end
    end

    context "with non-synced statuses" do
      it "accepts syncing status" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload.merge(status: "syncing"),
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(beacon.reload.sync_status).to eq("syncing")
      end

      it "accepts outdated status" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload.merge(status: "outdated"),
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(beacon.reload.sync_status).to eq("outdated")
      end

      it "accepts error status with error_message" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload.merge(status: "error", error_message: "Disk full"),
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(response).to have_http_status(:ok)
        beacon.reload
        expect(beacon.sync_status).to eq("error")
        expect(beacon.last_sync_error).to eq("Disk full")
      end
    end

    context "with an invalid status value" do
      it "returns 422 Unprocessable Entity" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload.merge(status: "banana"),
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("status is invalid")
      end

      it "does not update the beacon" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload.merge(status: "banana"),
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(beacon.reload.sync_status).to be_nil
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        post "/api/v1/beacons/sync_status", params: valid_payload, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a revoked beacon" do
      before { beacon.revoke! }

      it "returns 401 Unauthorized" do
        post "/api/v1/beacons/sync_status",
          params: valid_payload,
          headers: beacon_auth_headers(raw_key),
          as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
