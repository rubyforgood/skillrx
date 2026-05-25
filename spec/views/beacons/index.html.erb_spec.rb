require "rails_helper"

RSpec.describe "beacons/index", type: :view do
  context "when there are no beacons" do
    before do
      assign(:beacons, [])
      render
    end

    it "renders an empty state message" do
      assert_select "td", text: /No beacons provisioned yet/
    end

    it "renders the provision new beacon link" do
      assert_select "a", text: /Provision New Beacon/
    end
  end

  context "when there are beacons" do
    let(:active_beacon) { create(:beacon) }
    let(:revoked_beacon) { create(:beacon, :revoked) }

    before do
      assign(:beacons, [active_beacon, revoked_beacon])
      render
    end

    it "renders a row for each beacon" do
      assert_select "table tbody tr", count: 2
    end

    it "shows Active status for active beacons" do
      assert_select "td span", text: "Active"
    end

    it "shows Revoked status for revoked beacons" do
      assert_select "td span", text: "Revoked"
    end

    it "renders each beacon name" do
      assert_select "td", text: /#{active_beacon.name}/
      assert_select "td", text: /#{revoked_beacon.name}/
    end

    it "shows the active count in the header" do
      assert_select "span.text-green-600", text: "1"
    end

    it "shows the revoked count in the header" do
      assert_select "span.text-red-600", text: "1"
    end

    it "shows the total beacon count in the summary" do
      assert_select "p.text-3xl", text: "2"
    end

    it "renders the Status column header without text wrapping" do
      assert_select "th.whitespace-nowrap", text: /Status/
    end
  end
end
