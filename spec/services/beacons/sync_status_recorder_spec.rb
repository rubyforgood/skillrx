require "rails_helper"

RSpec.describe Beacons::SyncStatusRecorder do
  subject(:recorder) { described_class.new(beacon, clock: clock) }

  let(:beacon) { create(:beacon) }
  let(:now) { Time.zone.local(2026, 4, 21, 12, 0, 0) }
  let(:clock) { class_double(Time, current: now) }

  describe "#call" do
    let(:base_payload) do
      {
        status: "synced",
        manifest_version: "v43",
        manifest_checksum: "sha256:xyz",
        synced_at: "2026-04-21T11:59:00Z",
        files_count: 47,
        total_size_bytes: 156_000_000,
        device_info: { "hostname" => "clinic-pc-001", "os_version" => "Ubuntu 22.04", "app_version" => "1.0.0" },
      }
    end

    context "with a valid synced payload" do
      it "returns a successful result" do
        result = recorder.call(base_payload)

        expect(result.success).to be(true)
        expect(result.errors).to be_empty
      end

      it "persists the reported sync fields on the beacon" do
        recorder.call(base_payload)

        beacon.reload
        expect(beacon.sync_status).to eq("synced")
        expect(beacon.reported_manifest_version).to eq("v43")
        expect(beacon.reported_manifest_checksum).to eq("sha256:xyz")
        expect(beacon.reported_files_count).to eq(47)
        expect(beacon.reported_total_size_bytes).to eq(156_000_000)
        expect(beacon.device_info).to eq(base_payload[:device_info])
      end

      it "sets last_seen_at to the injected clock time" do
        recorder.call(base_payload)

        expect(beacon.reload.last_seen_at).to eq(now)
      end

      it "sets last_sync_at to the parsed synced_at timestamp" do
        recorder.call(base_payload)

        expect(beacon.reload.last_sync_at).to eq(Time.iso8601("2026-04-21T11:59:00Z"))
      end

      it "falls back to clock time when synced_at is missing for synced status" do
        recorder.call(base_payload.except(:synced_at))

        expect(beacon.reload.last_sync_at).to eq(now)
      end

      it "falls back to clock time when synced_at is malformed" do
        recorder.call(base_payload.merge(synced_at: "not-a-date"))

        expect(beacon.reload.last_sync_at).to eq(now)
      end
    end

    context "when status is not synced" do
      it "preserves last_sync_at for syncing status" do
        beacon.update!(last_sync_at: Time.zone.local(2026, 4, 20, 9, 0, 0))

        recorder.call(base_payload.merge(status: "syncing"))

        beacon.reload
        expect(beacon.sync_status).to eq("syncing")
        expect(beacon.last_sync_at).to eq(Time.zone.local(2026, 4, 20, 9, 0, 0))
        expect(beacon.last_seen_at).to eq(now)
      end

      it "updates last_seen_at for outdated status without touching last_sync_at" do
        beacon.update!(last_sync_at: Time.zone.local(2026, 4, 19, 8, 0, 0))

        recorder.call(base_payload.merge(status: "outdated"))

        beacon.reload
        expect(beacon.sync_status).to eq("outdated")
        expect(beacon.last_sync_at).to eq(Time.zone.local(2026, 4, 19, 8, 0, 0))
        expect(beacon.last_seen_at).to eq(now)
      end

      it "stores the error_message when status is error" do
        recorder.call(base_payload.merge(status: "error", error_message: "Network timeout"))

        beacon.reload
        expect(beacon.sync_status).to eq("error")
        expect(beacon.last_sync_error).to eq("Network timeout")
      end

      it "clears last_sync_error when status is not error" do
        beacon.update!(last_sync_error: "Previous failure")

        recorder.call(base_payload.merge(status: "syncing"))

        expect(beacon.reload.last_sync_error).to be_nil
      end
    end

    context "with an invalid status" do
      it "returns failure and does not touch the beacon" do
        result = recorder.call(base_payload.merge(status: "banana"))

        expect(result.success).to be(false)
        expect(result.errors).to include("status is invalid")

        beacon.reload
        expect(beacon.sync_status).to be_nil
        expect(beacon.last_seen_at).to be_nil
      end

      it "rejects a missing status" do
        result = recorder.call(base_payload.except(:status))

        expect(result.success).to be(false)
        expect(result.errors).to include("status is invalid")
      end
    end
  end
end
