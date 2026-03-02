require "rails_helper"

RSpec.describe BeaconsHelper, type: :helper do
  describe "#status_string" do
    subject { helper.status_string(beacon) }

    context "with an active beacon" do
      let(:beacon) { create(:beacon) }
      it { is_expected.to eq("Active") }
    end

    context "with a revoked beacon" do
      let(:beacon) { create(:beacon, :revoked) }
      it { is_expected.to eq("Revoked") }
    end
  end
end
