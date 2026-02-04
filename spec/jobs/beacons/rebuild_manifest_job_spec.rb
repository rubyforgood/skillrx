require "rails_helper"

RSpec.describe Beacons::RebuildManifestJob, type: :job do
  describe "#perform" do
    let(:beacon) { create(:beacon) }
    let(:manifest_builder) { instance_double(Beacons::ManifestBuilder, call: {}) }

    before do
      allow(Beacons::ManifestBuilder).to receive(:new).and_return(manifest_builder)
    end

    it "rebuilds the manifest for the given beacon" do
      described_class.perform_now(beacon.id)

      expect(Beacons::ManifestBuilder).to have_received(:new).with(beacon)
      expect(manifest_builder).to have_received(:call)
    end

    context "when the beacon does not exist" do
      it "returns early without building a manifest" do
        described_class.perform_now(-1)

        expect(Beacons::ManifestBuilder).not_to have_received(:new)
      end
    end
  end
end
