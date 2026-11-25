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
      assert_select "a", text: /Provision a beacon/
    end
  end

  context "when there are beacons" do
    let(:active_beacon) { create(:beacon) }
    let(:revoked_beacon) { create(:beacon, :revoked) }

    before do
      assign(:beacons, [ active_beacon, revoked_beacon ])
      render
    end

    it "renders a row for each beacon" do
      assert_select "table tbody tr", count: 2
    end

    it "shows each active beacon's sync status" do
      assert_select "td rfg-status-pill", text: "Never synced"
    end

    it "shows Revoked status for revoked beacons" do
      assert_select "td rfg-status-pill", text: "Revoked"
    end

    it "renders each beacon name" do
      assert_select "th[scope=row]", text: /#{active_beacon.name}/
      assert_select "th[scope=row]", text: /#{revoked_beacon.name}/
    end

    # Counts by status (docs/design/decisions.md, 2026-11-25). The factory's beacons have never
    # synced, so the active one counts there.
    it "counts beacons by status" do
      assert_select "dd[data-stat=total]", text: "2"
      assert_select "dd[data-stat=never]", text: "1"
      assert_select "dd[data-stat=revoked]", text: "1"
    end

    it "renders the Status column header" do
      assert_select "th[scope=col]", text: /Status/
    end
  end
end
