module Api
  module V1
    module Beacons
      class SyncStatusesController < Beacons::BaseController
        def create
          result = recorder.call(sync_status_params)

          if result.success
            render json: { status: "accepted" }, status: :ok
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        private

        def recorder
          ::Beacons::SyncStatusRecorder.new(Current.beacon)
        end

        def sync_status_params
          {
            status: params[:status],
            manifest_version: params[:manifest_version],
            manifest_checksum: params[:manifest_checksum],
            synced_at: params[:synced_at],
            files_count: params[:files_count],
            total_size_bytes: params[:total_size_bytes],
            error_message: params[:error_message],
            device_info: extract_device_info,
          }
        end

        def extract_device_info
          value = params[:device_info]
          return nil if value.blank?

          value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value
        end
      end
    end
  end
end
