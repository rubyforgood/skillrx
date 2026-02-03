module Api
  module V1
    module Devices
      class StatusesController < Devices::BaseController
        def show
          render json: {
            status: "ok",
            device: {
              id: Current.device.id,
              name: Current.device.name,
            },
          }
        end
      end
    end
  end
end
