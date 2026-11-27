require "rails_helper"

RSpec.describe ProviderRegionDataJob, type: :job do
  let(:language) { create(:language) }

  describe "#perform" do
    it "generates provider region data" do
      generator = instance_double(JsonGenerator::ProviderRegions)
      allow(JsonGenerator::ProviderRegions).to receive(:new).with(language).and_return(generator)
      expect(generator).to receive(:perform)

      described_class.perform_now(language.id)
    end

    context "when language does not exist" do
      it "raises an error" do
        expect { described_class.perform_now(-1) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
