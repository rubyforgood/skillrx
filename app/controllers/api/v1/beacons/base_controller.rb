module Api
  module V1
    module Beacons
      class BaseController < Api::V1::BaseController
        include Api::BeaconAuthentication
      end
    end
  end
end
