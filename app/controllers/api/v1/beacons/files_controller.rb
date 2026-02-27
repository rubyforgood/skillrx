module Api
  module V1
    module Beacons
      class FilesController < Beacons::BaseController
        include ActiveStorage::Streaming

        def show
          blob = Current.beacon.accessible_blobs.find(params[:id])

          if request.headers["Range"].present?
            send_blob_byte_range_data(blob, request.headers["Range"])
          else
            send_blob_stream(blob, disposition: :attachment)
          end
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
