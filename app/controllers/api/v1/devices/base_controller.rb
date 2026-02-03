module Api
  module V1
    module Devices
      class BaseController < Api::V1::BaseController
        include Api::DeviceAuthentication
      end
    end
  end
end
