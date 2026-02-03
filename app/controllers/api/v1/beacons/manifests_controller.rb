module Api
  module V1
    module Beacons
      class ManifestsController < Beacons::BaseController
        def show
          stored_etag = "v#{Current.beacon.manifest_version}"

          # During sync, beacon sends If-Match with its current version.
          # If the manifest changed since sync started, return 412 so beacon aborts and restarts.
          if stale_by_match?(stored_etag)
            response.headers["ETag"] = stored_etag
            head :precondition_failed
            return
          end

          # Beacon sends If-None-Match with its cached version to check for updates.
          # If versions match, return 304 — no sync needed.
          if fresh_by_none_match?(stored_etag)
            response.headers["ETag"] = stored_etag
            head :not_modified
            return
          end

          # Build full manifest only when we need to return the body
          manifest = manifest_builder.call
          response.headers["ETag"] = manifest[:manifest_version]
          render json: manifest
        end

        private

        def manifest_builder
          ::Beacons::ManifestBuilder.new(Current.beacon)
        end

        def stale_by_match?(etag)
          if_match = request.headers["If-Match"]
          return false if if_match.blank?

          if_match != etag
        end

        def fresh_by_none_match?(etag)
          if_none_match = request.headers["If-None-Match"]
          return false if if_none_match.blank?

          if_none_match == etag
        end
      end
    end
  end
end
