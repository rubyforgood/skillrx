module Api
  module V1
    module Beacons
      class StatusesController < Beacons::BaseController
        def show
          render json: {
            status: "ok",
            beacon: {
              id: Current.beacon.id,
              name: Current.beacon.name,
            },
          }
        end
      end
    end
  end
end
