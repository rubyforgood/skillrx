module Beacons
  class SyncStatusRecorder
    Result = Data.define(:success, :errors)

    def initialize(beacon, clock: Time)
      @beacon = beacon
      @clock = clock
    end

    def call(payload)
      attrs = normalize(payload)
      return Result.new(success: false, errors: [ "status is invalid" ]) unless valid_status?(attrs[:sync_status])

      beacon.update!(attrs)
      Result.new(success: true, errors: [])
    end

    private

    attr_reader :beacon, :clock

    def normalize(payload)
      now = clock.current
      status = payload[:status].to_s

      {
        sync_status: status,
        last_seen_at: now,
        last_sync_at: last_sync_at_for(status, payload[:synced_at]),
        reported_manifest_version: payload[:manifest_version],
        reported_manifest_checksum: payload[:manifest_checksum],
        reported_files_count: payload[:files_count],
        reported_total_size_bytes: payload[:total_size_bytes],
        last_sync_error: status == "error" ? payload[:error_message] : nil,
        device_info: payload[:device_info],
      }
    end

    def last_sync_at_for(status, synced_at)
      return beacon.last_sync_at unless status == "synced"

      parse_time(synced_at) || clock.current
    end

    def parse_time(value)
      return nil if value.blank?

      Time.iso8601(value.to_s)
    rescue ArgumentError
      nil
    end

    def valid_status?(status)
      Beacon::SYNC_STATUSES.include?(status)
    end
  end
end
