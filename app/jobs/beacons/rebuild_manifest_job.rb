module Beacons
  class RebuildManifestJob < ApplicationJob
    queue_as :default

    def perform(beacon_id)
      beacon = Beacon.find_by(id: beacon_id)
      return unless beacon

      ManifestBuilder.new(beacon).call
    end
  end
end
